`timescale 1ns / 1ps
//============================================================
// OP_CONTROL - 연산 + LSU 컨트롤 (opcode 디코드 + FSM + RF 주소)
//   single in-flight. 동기 FIFO.
//
//   연산 (4~17): FETCH→DECODE→READ→COMP→WRITE (5 cycle)
//   LSU  (0~3):  FETCH→DECODE→LSU_REQ→LSU_WAIT→LSU_DONE
//     Load:  cache_req → cache_valid 대기 → RF write
//     Store: RF read(1cyc) → cache_req(we) → valid 대기
//
//   v4: LDV 목적지 주소 공간 6b 확장 (v3 동일) = {src2[0], dst[4:0]}
//     0~31        : VRF 엔트리 (기존과 동일, src2=0)
//     32+ (coeff) : dst[2]=RAM 선택 (0=V_PWL, 1=S_PWL), dst[1:0]=LUT 라인 (0~1)
//       32~33 = V_PWL LUT (0=SiLU,1=exp) / 36~37 = S_PWL LUT (0=rsqrt,1=1/S)
//     별도 coeff instruction 없음. LUT(knot+계수)는 캐시에 두고 LDV로 인출. 레이어별 swap.
//
//   v5: OP_ESUB(18) 추가 — elementwise 벡터-벡터 뺄셈 (RoPE 회전용)
//     ALU_LANE 의 OP_SUB 경로가 이미 있었으나 (V_ALU, alu_op=2'b10) 조합을
//     쓰는 opcode 가 없었음. 디코드 테이블 추가만, 신규 게이트 0.
//============================================================
module OP_CONTROL (
    input         clk, rst_n,
    // INSTR_FIFO
    input  [19:0] instr,
    input         deq_valid,
    output reg    deq_ready,
    // VRF
    output reg        vrf_rd1_re, vrf_rd2_re,
    output reg [4:0]  vrf_rd1_addr, vrf_rd2_addr,
    output reg        vrf_wr_en,
    output reg [4:0]  vrf_wr_addr,
    output reg        vrf_wr_sel,    // 0=datapath result, 1=LSU(Load)
    // SRF
    output reg        srf_rd1_re, srf_rd2_re,
    output reg [4:0]  srf_rd1_addr, srf_rd2_addr,
    output reg        srf_wr_en,
    output reg [4:0]  srf_wr_addr,
    output reg        srf_cache_wr_en,  // Load_scalar (512b 전체)
    // COEFF (LDV coeff 공간 → 캐시 라인 write)
    output reg        pwl_coeff_wr_en,  // VEC PWL COEFF_RAM
    output reg        sfu_coeff_wr_en,  // ACCUM SFU COEFF_RAM
    output reg [1:0]  coeff_line_addr,  // LUT 라인 인덱스 (0~1)
    // VEC_DATAPATH
    output reg [1:0]  vec_mode,
    output reg [1:0]  vec_alu_op,
    output reg        vec_sq, vec_pwl_op, vec_red_op,
    // SCALAR_DATAPATH
    output reg [1:0]  accum_mode,
    output reg [2:0]  acc_salu_op,
    output reg        acc_op, acc_sfu_op, acc_flush,
    // result 선택 (datapath)
    output reg        wr_sel,        // 0=VEC, 1=ACCUM
    // LSU / 캐시
    output reg [1:0]  lsu_op,
    output reg        cache_req,
    output reg        cache_we,      // 0=read(Load), 1=write(Store)
    output reg [31:0] cache_addr,
    input             cache_valid
);
    localparam OP_LDV=5'd0, OP_STV=5'd1, OP_LDS=5'd2, OP_STS=5'd3;
    localparam OP_SILU=5'd4, OP_SQ=5'd5, OP_EXP=5'd6,
               OP_EMUL=5'd7, OP_EADD=5'd8,
               OP_SCMUL=5'd9, OP_VSADD=5'd10, OP_VSSUB=5'd11,
               OP_RSQRT=5'd12, OP_RECIP=5'd13,
               OP_SADD=5'd14, OP_SMUL=5'd15,
               OP_RED=5'd16, OP_MAX=5'd17,
               OP_ESUB=5'd18;   // v5: elementwise 벡터-벡터 뺄셈 (RoPE 회전용)
    localparam V_ALU=2'b00, V_PWL=2'b01, V_RED=2'b10, V_SCALE=2'b11;
    localparam A_SALU=2'b00, A_ACCUM=2'b01, A_SFU=2'b10;
    localparam S_ADD=3'b000, S_SUB=3'b001, S_MUL=3'b010, S_MAX=3'b011, S_MADD=3'b100;

    // FSM
    localparam ST_FETCH=4'd0, ST_DECODE=4'd1, ST_READ=4'd2, ST_COMP=4'd3, ST_WRITE=4'd4,
               ST_LSU_REQ=4'd5, ST_LSU_WAIT=4'd6, ST_LSU_DONE=4'd7;
    reg [3:0] state;

    reg [4:0] op_r, src1_r, src2_r, dst_r;
    // v3: LDV coeff 공간 래치
    reg       ldv_coeff_r;      // 1=목적지가 coeff 공간 (src2[0])
    reg       coeff_ram_r;      // 0=V_PWL, 1=S_PWL (dst[2])
    wire [4:0] opcode = instr[19:15];
    wire [4:0] src1   = instr[14:10];
    wire [4:0] src2   = instr[9:5];
    wire [4:0] dst    = instr[4:0];
    wire is_lsu = (opcode <= OP_STS);   // 0~3

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= ST_FETCH; deq_ready<=0;
            vrf_rd1_re<=0; vrf_rd2_re<=0; vrf_wr_en<=0; vrf_wr_sel<=0;
            srf_rd1_re<=0; srf_rd2_re<=0; srf_wr_en<=0; srf_cache_wr_en<=0;
            pwl_coeff_wr_en<=0; sfu_coeff_wr_en<=0;
            cache_req<=0; cache_we<=0; acc_flush<=0;
            ldv_coeff_r<=0; coeff_ram_r<=0;
        end else begin
            // 기본값
            deq_ready<=0;
            vrf_rd1_re<=0; vrf_rd2_re<=0; vrf_wr_en<=0;
            srf_rd1_re<=0; srf_rd2_re<=0; srf_wr_en<=0; srf_cache_wr_en<=0;
            pwl_coeff_wr_en<=0; sfu_coeff_wr_en<=0;
            cache_req<=0;

            case (state)
            //========== FETCH ==========
            ST_FETCH: begin
                if (deq_valid) begin deq_ready<=1; state<=ST_DECODE; end
            end
            //========== DECODE ==========
            ST_DECODE: begin
                op_r<=opcode; src1_r<=src1; src2_r<=src2; dst_r<=dst;
                vrf_rd1_addr<=src1; vrf_rd2_addr<=src2;
                srf_rd1_addr<=src1; srf_rd2_addr<=src2;

                if (opcode <= OP_STS) begin
                    lsu_op <= opcode[1:0];
                    // Load: 캐시[src1] → RF[dst]. 캐시주소=src1
                    // Store: RF[src1] → 캐시[dst]. 캐시주소=dst, VRF read=src1
                    case (opcode)
                        OP_LDV: begin
                            cache_addr <= {27'd0, src1};
                            // v3: 목적지 공간 디코드 {src2[0], dst}
                            ldv_coeff_r     <= src2[0];   // 1=coeff 공간
                            coeff_ram_r     <= dst[2];    // 0=V_PWL, 1=S_PWL
                            coeff_line_addr <= dst[1:0];  // LUT 라인 0~1
                        end
                        OP_LDS: begin cache_addr <= {27'd0, src1}; ldv_coeff_r<=0; end
                        OP_STV: begin cache_addr <= {27'd0, dst}; vrf_rd1_re<=1; ldv_coeff_r<=0; end // Store_vec: dst=캐시, VRF[src1] read
                        OP_STS: begin cache_addr <= {27'd0, dst}; ldv_coeff_r<=0; end               // Store_sc: dst=캐시
                    endcase
                    state <= ST_LSU_REQ;
                end else begin
                    // 연산 opcode (re 발행)
                    case (opcode)
                        OP_SILU,OP_SQ,OP_EXP: begin vrf_rd1_re<=1; vrf_rd2_re<=0; end
                        OP_EMUL,OP_EADD,OP_ESUB: begin vrf_rd1_re<=1; vrf_rd2_re<=1; end
                        OP_SCMUL,OP_VSADD,OP_VSSUB: begin vrf_rd1_re<=1; srf_rd1_re<=1; srf_rd1_addr<=src2; end
                        OP_RED,OP_MAX:        begin vrf_rd1_re<=1; vrf_rd2_re<=0; end
                        OP_RSQRT,OP_RECIP:    begin srf_rd1_re<=1; end
                        OP_SADD,OP_SMUL:      begin srf_rd1_re<=1; srf_rd2_re<=1; end
                    endcase
                    state <= ST_READ;
                end
            end
            //========== READ (datapath 제어) ==========
            ST_READ: begin
                case (op_r)
                    OP_SILU:  begin vec_mode<=V_PWL; vec_pwl_op<=0; wr_sel<=0; end
                    OP_EXP:   begin vec_mode<=V_PWL; vec_pwl_op<=1; wr_sel<=0; end
                    OP_SQ:    begin vec_mode<=V_ALU; vec_sq<=1; vec_alu_op<=2'b00; wr_sel<=0; end
                    OP_EMUL:  begin vec_mode<=V_ALU; vec_sq<=0; vec_alu_op<=2'b00; wr_sel<=0; end
                    OP_EADD:  begin vec_mode<=V_ALU; vec_sq<=0; vec_alu_op<=2'b01; wr_sel<=0; end
                    OP_ESUB:  begin vec_mode<=V_ALU; vec_sq<=0; vec_alu_op<=2'b10; wr_sel<=0; end
                    OP_SCMUL: begin vec_mode<=V_SCALE; vec_sq<=0; vec_alu_op<=2'b00; wr_sel<=0; end
                    OP_VSADD: begin vec_mode<=V_SCALE; vec_sq<=0; vec_alu_op<=2'b01; wr_sel<=0; end
                    OP_VSSUB: begin vec_mode<=V_SCALE; vec_sq<=0; vec_alu_op<=2'b10; wr_sel<=0; end
                    OP_RED:   begin vec_mode<=V_RED; vec_red_op<=0; wr_sel<=0; end
                    OP_MAX:   begin vec_mode<=V_RED; vec_red_op<=1; wr_sel<=0; end
                    OP_RSQRT: begin accum_mode<=A_SFU; acc_sfu_op<=0; wr_sel<=1; end
                    OP_RECIP: begin accum_mode<=A_SFU; acc_sfu_op<=1; wr_sel<=1; end
                    OP_SADD:  begin accum_mode<=A_SALU; acc_salu_op<=S_ADD; wr_sel<=1; end
                    OP_SMUL:  begin accum_mode<=A_SALU; acc_salu_op<=S_MUL; wr_sel<=1; end
                endcase
                state <= ST_COMP;
            end
            //========== COMP (datapath 출력 FF 대기) ==========
            ST_COMP: state <= ST_WRITE;
            //========== WRITE (result → RF) ==========
            ST_WRITE: begin
                vrf_wr_sel <= 0;   // datapath result
                case (op_r)
                    OP_SILU,OP_SQ,OP_EXP,OP_EMUL,OP_EADD,OP_ESUB,
                    OP_SCMUL,OP_VSADD,OP_VSSUB:
                        begin vrf_wr_en<=1; vrf_wr_addr<=dst_r; end
                    OP_RED,OP_MAX,OP_RSQRT,OP_RECIP,OP_SADD,OP_SMUL:
                        begin srf_wr_en<=1; srf_wr_addr<=dst_r; end
                endcase
                state <= ST_FETCH;
            end
            //========== LSU_REQ (캐시 요청) ==========
            ST_LSU_REQ: begin
                cache_req <= 1;
                // Load=read(we=0), Store=write(we=1)
                cache_we <= (lsu_op==2'd1 || lsu_op==2'd3);  // St_vec/St_sc
                state <= ST_LSU_WAIT;
            end
            //========== LSU_WAIT (cache_valid 대기) ==========
            ST_LSU_WAIT: begin
                if (cache_valid) begin
                    // Load면 RF/coeff write
                    case (lsu_op)
                        2'd0: begin // Ld_vec: coeff 공간이면 COEFF_RAM 라인, 아니면 VRF
                            if (ldv_coeff_r) begin
                                if (coeff_ram_r) sfu_coeff_wr_en<=1;
                                else             pwl_coeff_wr_en<=1;
                            end else begin
                                vrf_wr_en<=1; vrf_wr_addr<=dst_r; vrf_wr_sel<=1;
                            end
                        end
                        2'd2: begin srf_cache_wr_en<=1; end                              // Ld_sc (512b)
                        default: ;  // Store는 캐시가 받음, RF write 없음
                    endcase
                    state <= ST_LSU_DONE;
                end else begin
                    cache_req <= 1;  // valid까지 req 유지
                end
            end
            //========== LSU_DONE ==========
            ST_LSU_DONE: state <= ST_FETCH;
            endcase
        end
    end
endmodule
