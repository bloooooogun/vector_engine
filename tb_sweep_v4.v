`timescale 1ns/1ps
//============================================================
// tb_sweep_v4 - 전 LUT 스윕 검증 (66개 LUT 전부, bit-exact)
//
//   silu 16 레이어 / exp 1 global / rsqrt 33 모듈 / 1_over_S 16 레이어
//   각 LUT마다 테스트 포인트 32개 (범위 안 30 + 범위 밖 2, 클램프 확인)
//
//   벡터 함수 (silu/exp):  LDV LUT → LDV 입력 → SILU/EXP → STV → 32워드 비교
//   스칼라 함수 (rsqrt/1S): LDV LUT → LDS 입력(32 스칼라) → op x32 (SRF[j]→SRF[j])
//                          → STS → 32워드 비교
//   golden = gen_luts_from_xlsx.py 가 BF16 단계까지 에뮬레이션 → 전부 bit-exact 기대
//============================================================
module tb_sweep_v4;
    reg clk, rst_n;
    reg [19:0] instr_in; reg enq_valid; wire enq_ready;
    wire cache_req, cache_we; wire [31:0] cache_addr;
    wire [511:0] cache_wdata; reg [511:0] cache_rdata_r; reg cache_valid;

    localparam LUT_CADDR = 8'd11;   // LUT 라인 staging
    localparam IN_CADDR  = 8'd12;   // 테스트 입력 라인
    localparam RES_CADDR = 8'd20;   // 결과 store

    reg [511:0] fake_cache [0:255];
    always @(posedge clk) begin
        cache_valid <= 0;
        if (cache_req && !cache_we)
            begin cache_rdata_r <= fake_cache[cache_addr[7:0]]; cache_valid <= 1; end
        else if (cache_req && cache_we)
            begin fake_cache[cache_addr[7:0]] <= cache_wdata; cache_valid <= 1; end
    end

    VECTOR_ENGINE dut (
        .clk(clk),.rst_n(rst_n),
        .instr_in(instr_in),.enq_valid(enq_valid),.enq_ready(enq_ready),
        .cache_req(cache_req),.cache_we(cache_we),.cache_addr(cache_addr),
        .cache_wdata(cache_wdata),.cache_rdata(cache_rdata_r),.cache_valid(cache_valid)
    );
    always #5 clk=~clk;

    function real b2r; input [15:0] b; reg s; integer e; reg [6:0] m; real f; integer i;
        begin s=b[15];e=b[14:7];m=b[6:0];if(e==0)b2r=0.0;else begin f=1.0;
        for(i=0;i<7;i=i+1)if(m[i])f=f+(1.0/(1<<(7-i)));e=e-127;
        if(e>=0)for(i=0;i<e;i=i+1)f=f*2.0;else for(i=0;i<-e;i=i+1)f=f/2.0;b2r=s?-f:f;end end
    endfunction
    // IEEE754 f32 비트 → real (진값 판독용)
    function real f32r; input [31:0] b; reg s; integer e; reg [22:0] m; real f; integer i;
        begin s=b[31];e=b[30:23];m=b[22:0];if(e==0)f32r=0.0;else begin f=1.0;
        for(i=0;i<23;i=i+1)if(m[i])f=f+(1.0/(2.0**(23-i)));e=e-127;
        if(e>=0)for(i=0;i<e;i=i+1)f=f*2.0;else for(i=0;i<-e;i=i+1)f=f/2.0;f32r=s?-f:f;end end
    endfunction

    reg [19:0] prog [0:63]; integer prog_len, pc;
    function [19:0] I; input [4:0] op,s1,s2,d; I={op,s1,s2,d}; endfunction
    task send_program; begin
        pc=0;
        while(pc<prog_len) begin
            @(negedge clk); instr_in=prog[pc]; enq_valid=1;
            @(posedge clk); if(enq_ready) pc=pc+1;
        end
        @(negedge clk); enq_valid=0;
    end endtask

    `include "all_luts.vh"
    `include "v4_sweep.vh"

    integer m, j, mism, total_mism, total_pts;

    // ---- 벡터 함수 1개 LUT 실행: LUT 로드 → 입력 로드 → op → store ----
    task run_vec; input [4:0] opcode; input [4:0] lut_dst; begin
        prog[0] = I(5'd0, LUT_CADDR[4:0], 5'd1, lut_dst);   // LDV LUT (coeff 공간)
        prog[1] = I(5'd0, IN_CADDR[4:0],  5'd0, 5'd0);      // LDV 입력 → VRF0
        prog[2] = I(opcode, 5'd0, 5'd0, 5'd1);              // op VRF0→VRF1
        prog[3] = I(5'd1, 5'd1, 5'd0, RES_CADDR[4:0]);      // STV → 결과
        prog_len = 4;
        send_program;
        repeat(45) @(posedge clk);
    end endtask

    // ---- 스칼라 함수 1개 LUT 실행: LUT 로드 → LDS → op x32 (in-place) → STS ----
    task run_scal; input [4:0] opcode; input [4:0] lut_dst; begin
        prog[0] = I(5'd0, LUT_CADDR[4:0], 5'd1, lut_dst);   // LDV LUT (coeff 공간)
        prog[1] = I(5'd2, IN_CADDR[4:0],  5'd0, 5'd0);      // LDS 입력 → SRF 전체
        for (j=0; j<32; j=j+1)
            prog[2+j] = I(opcode, j[4:0], 5'd0, j[4:0]);    // op SRF[j]→SRF[j]
        prog[34] = I(5'd3, 5'd0, 5'd0, RES_CADDR[4:0]);     // STS → 결과
        prog_len = 35;
        send_program;
        repeat(60) @(posedge clk);
    end endtask

    // ---- 결과 32워드 vs golden bit 비교 + 진값 대비 오차 (전 포인트 출력) ----
    //   golden = LUT 에뮬레이션 (HW 정확성 판정 기준, bit 비교)
    //   true   = 실제 함수 (CPU double, pytorch 동급) — err = |HW - true| (LUT 근사 품질)
    real tru, aerr, lut_maxe;
    task check32; input [8*6:1] nm; input integer idx; input integer base; begin : chk
        integer k; reg [15:0] g, hw, xin; reg [31:0] t;
        mism = 0; lut_maxe = 0;
        $display("  ---- %0s[%0d] ----", nm, idx);
        for (k=0; k<32; k=k+1) begin
            case (nm)
            "silu": begin g = sw_silu_gold[base+k]; t = sw_silu_true[base+k]; end
            "exp":  begin g = sw_exp_gold [base+k]; t = sw_exp_true [base+k]; end
            "rsq":  begin g = sw_rsq_gold [base+k]; t = sw_rsq_true [base+k]; end
            "oos":  begin g = sw_oos_gold [base+k]; t = sw_oos_true [base+k]; end
            endcase
            hw  = fake_cache[RES_CADDR][k*16+:16];
            xin = fake_cache[IN_CADDR ][k*16+:16];
            tru  = f32r(t);
            aerr = b2r(hw) - tru; if (aerr < 0) aerr = -aerr;
            if (aerr > lut_maxe) lut_maxe = aerr;
            if (hw !== g) begin
                mism = mism + 1;
                $display("    pt%2d: x=%13.6g  HW=%13.6g (%h)  golden=%13.6g (%h)  true=%13.6g  err=%10.4g  <-- MISMATCH",
                         k, b2r(xin), b2r(hw), hw, b2r(g), g, tru, aerr);
            end else
                $display("    pt%2d: x=%13.6g  HW=%13.6g (%h)  golden=%13.6g (%h)  true=%13.6g  err=%10.4g  OK",
                         k, b2r(xin), b2r(hw), hw, b2r(g), g, tru, aerr);
        end
        total_mism = total_mism + mism;
        total_pts  = total_pts + 32;
        $display("  %0s[%0d]: %0d/32 mismatch [%s],  max|HW-true| = %.5g",
                 nm, idx, mism, mism==0?"PASS":"FAIL", lut_maxe);
    end endtask

    initial begin
        clk=0; rst_n=0; enq_valid=0; instr_in=0; cache_valid=0;
        total_mism=0; total_pts=0;
        set_silu_gold; set_exp_gold; set_rsq_gold; set_oos_gold;
        #12; rst_n=1;

        // ===== SiLU: 16 레이어 =====
        $display("===== SiLU sweep (%0d layers x 32 pts) =====", N_SILU);
        for (m=0; m<N_SILU; m=m+1) begin
            set_silu_lut(LUT_CADDR, m);
            set_silu_in (IN_CADDR,  m);
            run_vec(5'd4, 5'd0);                 // SILU, V_PWL line0
            check32("silu", m, m*32);
        end
        $display("  silu done. cumulative mismatch=%0d", total_mism);

        // ===== exp: global =====
        $display("===== exp sweep (%0d x 32 pts) =====", N_EXP);
        for (m=0; m<N_EXP; m=m+1) begin
            set_exp_lut(LUT_CADDR, m);
            set_exp_in (IN_CADDR,  m);
            run_vec(5'd6, 5'd1);                 // EXP, V_PWL line1
            check32("exp", m, m*32);
        end
        $display("  exp done. cumulative mismatch=%0d", total_mism);

        // ===== rsqrt: 33 모듈 =====
        $display("===== rsqrt sweep (%0d modules x 32 pts) =====", N_RSQ);
        for (m=0; m<N_RSQ; m=m+1) begin
            set_rsqrt_lut(LUT_CADDR, m);
            set_rsq_in   (IN_CADDR,  m);
            run_scal(5'd12, 5'd4);               // RSQRT, S_PWL line0
            check32("rsq", m, m*32);
        end
        $display("  rsqrt done. cumulative mismatch=%0d", total_mism);

        // ===== 1_over_S: 16 레이어 =====
        $display("===== 1_over_S sweep (%0d layers x 32 pts) =====", N_OOS);
        for (m=0; m<N_OOS; m=m+1) begin
            set_recip_lut(LUT_CADDR, m);
            set_oos_in   (IN_CADDR,  m);
            run_scal(5'd13, 5'd5);               // RECIP(1/S), S_PWL line1
            check32("oos", m, m*32);
        end

        $display("\n===== SWEEP RESULT: %0d LUTs, %0d points, %0d mismatch  [%s] =====",
                 N_SILU+N_EXP+N_RSQ+N_OOS, total_pts, total_mism,
                 total_mism==0 ? "ALL PASS (bit-exact)" : "FAIL");
        $finish;
    end
endmodule
