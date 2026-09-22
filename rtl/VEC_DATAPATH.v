`timescale 1ns / 1ps
//============================================================
// VEC_DATAPATH - vector 구획 (조합 연산 + 출력 레지스터)
//   내부: 완전 조합 (ALU / PWL / REDUCE / scale)
//   출력: FF 1벌로 래치 → 1 cycle latency
//   v4: non-uniform PWL
//     - PWL 모드 ALU x 입력 = x_eff (범위 밖: 경계 knot 대입)
//     - 범위 밖 정책 (함수별):
//         exp  (pwl_op=1): 끝점 연장 — x_eff 클램프 결과 그대로
//         SiLU (pwl_op=0): 하한(lo) → 0, 상한(hi) → x (identity)
//============================================================
module VEC_DATAPATH (
    input  clk, rst_n,
    input  [511:0] vrf_rd1, vrf_rd2,
    input  [15:0]  srf_scalar,
    input  [1:0]   VEC_MODE,            // ALU=00 / PWL=01 / REDUCE=10 / scale=11
    input  [1:0]   alu_op,
    input          sq_flag,
    input          pwl_op,
    input          red_op,
    input          coeff_wr_en,
    input  [1:0]   coeff_wr_line,       // 함수 라인: 0=SiLU, 1=exp
    input  [511:0] coeff_wr_data,       // 캐시 라인 데이터 (LUT 1벌)
    output reg [511:0] result_vec,      // 등록 출력
    output reg [15:0]  result_scalar    // 등록 출력
);
    wire [511:0] coeff_a_vec, coeff_b_vec, x_eff_vec;
    wire [31:0]  lo_vec, hi_vec;
    wire [511:0] ALU_VEC_IN1, ALU_VEC_IN2;
    wire [511:0] ALU_OUT;
    wire [15:0]  REDUCE_OUT;
    wire [511:0] scalar_broadcast;

    assign scalar_broadcast = {32{srf_scalar}};
    // PWL: x 자리에 x_eff (클램프 반영), operand2 자리에 계수 a
    assign ALU_VEC_IN1 = (VEC_MODE==2'b01) ? x_eff_vec : vrf_rd1;
    assign ALU_VEC_IN2 = (VEC_MODE==2'b01) ? coeff_a_vec :
                         (VEC_MODE==2'b11) ? scalar_broadcast : vrf_rd2;

    wire [1:0] alu_op_eff = (VEC_MODE==2'b01) ? 2'd3 : alu_op;
    wire       sq_eff     = (VEC_MODE==2'b00) ? sq_flag : 1'b0;  // ALU 모드만 sq

    V_ALU u_V_ALU(
        .VEC_IN1(ALU_VEC_IN1), .VEC_IN2(ALU_VEC_IN2), .VEC_IN3(coeff_b_vec),
        .CTRL_ALU_OP(alu_op_eff), .SQUARE_FLAG(sq_eff), .VEC_OUT(ALU_OUT)
    );
    V_PWL u_V_PWL(
        .clk(clk), .rst_n(rst_n), .pwl_op(pwl_op),
        .wr_en(coeff_wr_en), .wr_line(coeff_wr_line), .wr_data(coeff_wr_data),
        .x_vec(vrf_rd1),
        .coeff_a_vec(coeff_a_vec), .coeff_b_vec(coeff_b_vec),
        .x_eff_vec(x_eff_vec), .lo_vec(lo_vec), .hi_vec(hi_vec)
    );
    REDUCE u_REDUCE(.vec_in(vrf_rd1), .red_op(red_op), .y(REDUCE_OUT));

    // ---- SiLU 범위 밖 마스크 (SiLU 모드에서만: lo → 0, hi → x) ----
    //   exp 는 마스크 없이 x_eff 클램프 결과 (끝점 연장)
    wire is_silu = (VEC_MODE==2'b01) & ~pwl_op;
    wire [31:0] force0_valid = lo_vec & {32{is_silu}};
    wire [31:0] pass_x_valid = hi_vec & {32{is_silu}};

    // ---- 조합 결과 ----
    wire [511:0] result_vec_comb;
    genvar gi;
    generate
        for (gi=0; gi<32; gi=gi+1) begin: output_mux
            assign result_vec_comb[gi*16 +: 16] =
                force0_valid[gi] ? 16'h0000             :
                pass_x_valid[gi] ? vrf_rd1[gi*16 +: 16] :
                                   ALU_OUT[gi*16 +: 16];
        end
    endgenerate
    wire [15:0]  result_scalar_comb = REDUCE_OUT;

    // ---- 출력 레지스터 (1 cycle latency) ----
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            result_vec    <= 512'h0;
            result_scalar <= 16'h0;
        end else begin
            result_vec    <= result_vec_comb;
            result_scalar <= result_scalar_comb;
        end
    end
endmodule
