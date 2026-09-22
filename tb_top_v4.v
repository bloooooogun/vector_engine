`timescale 1ns/1ps
//============================================================
// tb_top_v4 - VECTOR_ENGINE v4 testbench (non-uniform LUT, post-synth safe)
//
//   include (gen_luts_from_xlsx.py 로 생성):
//     all_luts.vh : set_silu_lut/set_exp_lut/set_rsqrt_lut/set_recip_lut
//                   (idx = 레이어/모듈 번호, fake_cache 라인 staging)
//     v4_data.vh  : 테스트 입력 + LUT-emulated golden
//
//   LUT 로드 = LDV coeff 공간 (src2=1):
//     dst=0: V_PWL SiLU / dst=1: V_PWL exp / dst=4: S_PWL rsqrt / dst=5: S_PWL 1/S
//   골든은 LUT 자체 기준 (HW가 LUT를 정확히 구현하는지 검증)
//   SiLU 입력 lane30/31 = ±5.0 → 클램프 (x_eff=±4 경계) 경로 확인
//============================================================
module tb_top_v4;
    reg clk, rst_n;
    reg [19:0] instr_in; reg enq_valid; wire enq_ready;
    wire cache_req, cache_we; wire [31:0] cache_addr;
    wire [511:0] cache_wdata; reg [511:0] cache_rdata_r; reg cache_valid;

    // LUT staging 캐시 주소
    localparam SILU_CADDR  = 8'd11;
    localparam EXP_CADDR   = 8'd12;
    localparam RSQRT_CADDR = 8'd13;
    localparam RECIP_CADDR = 8'd14;

    // fake cache (1cyc delay)
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

    // STORE_MON: trace cache writes
    always @(posedge clk) if(cache_req && cache_we)
        $display("  [STORE] addr=%0d wdata[15:0]=%h(%.3f)", cache_addr, cache_wdata[15:0], b2r(cache_wdata[15:0]));


    function real b2r; input [15:0] b; reg s; integer e; reg [6:0] m; real f; integer i;
        begin s=b[15];e=b[14:7];m=b[6:0];if(e==0)b2r=0.0;else begin f=1.0;
        for(i=0;i<7;i=i+1)if(m[i])f=f+(1.0/(1<<(7-i)));e=e-127;
        if(e>=0)for(i=0;i<e;i=i+1)f=f*2.0;else for(i=0;i<-e;i=i+1)f=f/2.0;b2r=s?-f:f;end end
    endfunction
    function [15:0] r2b; input real r; integer ev; reg s; real af; reg [6:0] m; integer i;
        begin if(r==0.0)r2b=0;else begin s=(r<0);af=s?-r:r;ev=0;
        while(af>=2.0)begin af=af/2.0;ev=ev+1;end while(af<1.0)begin af=af*2.0;ev=ev-1;end
        af=af-1.0;m=0;for(i=0;i<7;i=i+1)begin af=af*2.0;if(af>=1.0)begin m[6-i]=1;af=af-1.0;end end
        r2b={s,ev[7:0]+8'd127,m};end end
    endfunction

    // instruction issue (enq_ready handshake)
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
    task set_cache; input [7:0] addr; input [15:0] val; integer i; begin
        for(i=0;i<32;i=i+1) fake_cache[addr][i*16+:16]=val; end
    endtask
    integer errs;
    task chk; input [7:0] caddr; input real golden; input real tol; input [8*14:1] nm; real got; begin
        got=b2r(fake_cache[caddr][15:0]);
        if(got<golden-tol||got>golden+tol) begin errs=errs+1;
            $display("  FAIL %0s: cache[%0d]=%.4f (golden %.4f)",nm,caddr,got,golden); end
        else $display("  OK   %0s: cache[%0d]=%.4f (golden %.4f)",nm,caddr,got,golden);
    end endtask

    `include "all_luts.vh"
    `include "v4_data.vh"

    // LUT 4개 staging + LDV 로드 (레이어 진입 시마다 호출하는 시퀀스와 동일)
    task load_layer_luts; input integer silu_i, exp_i, rsqrt_i, recip_i; begin
        set_silu_lut (SILU_CADDR,  silu_i);
        set_exp_lut  (EXP_CADDR,   exp_i);
        set_rsqrt_lut(RSQRT_CADDR, rsqrt_i);
        set_recip_lut(RECIP_CADDR, recip_i);
        prog[0] = I(5'd0, SILU_CADDR[4:0],  5'd1, 5'd0);  // → V_PWL line0 (SiLU)
        prog[1] = I(5'd0, EXP_CADDR[4:0],   5'd1, 5'd1);  // → V_PWL line1 (exp)
        prog[2] = I(5'd0, RSQRT_CADDR[4:0], 5'd1, 5'd4);  // → S_PWL line0 (rsqrt)
        prog[3] = I(5'd0, RECIP_CADDR[4:0], 5'd1, 5'd5);  // → S_PWL line1 (1/S)
        prog_len = 4;
        send_program;
        repeat(40) @(posedge clk);
    end endtask

    initial begin
        clk=0; rst_n=0; enq_valid=0; instr_in=0; cache_valid=0;
        errs=0; #12; rst_n=1;

        // ===== LUT load (v4_data.vh 가 고른 모듈/레이어) =====
        $display("===== LUT load via LDV (4 lines: silu/exp/rsqrt/1_over_S) =====");
        load_layer_luts(TB_SILU_IDX, TB_EXP_IDX, TB_RSQRT_IDX, TB_RECIP_IDX);

        // ===== input cache =====
        set_cache(0, r2b(3.0));
        set_cache(1, r2b(2.0));
        set_cache(2, r2b(1.0));     // SiLU(1.0)
        set_cache(3, r2b(-2.0));    // exp(-2)
        set_cache(4, r2b(4.0));     // rsqrt(4)

        // ===== program =====
        $display("\n===== Instruction sequence =====");
        prog[0] = I(5'd0, 5'd0, 5'd0, 5'd0);  // Ld 3→VRF0
        prog[1] = I(5'd0, 5'd1, 5'd0, 5'd1);  // Ld 2→VRF1
        prog[2] = I(5'd0, 5'd2, 5'd0, 5'd2);  // Ld 1->VRF2 (for SiLU)
        prog[3] = I(5'd0, 5'd3, 5'd0, 5'd3);  // Ld -2->VRF3 (for exp)
        prog[4] = I(5'd7, 5'd0, 5'd1, 5'd4);  // EMUL 3*2=6
        prog[5] = I(5'd4, 5'd2, 5'd0, 5'd5);  // SiLU(1.0)
        prog[6] = I(5'd6, 5'd3, 5'd0, 5'd6);  // exp(-2)
        prog[7] = I(5'd1, 5'd4, 5'd0, 5'd20); // EMUL→cache20
        prog[8] = I(5'd1, 5'd5, 5'd0, 5'd21); // SiLU→cache21
        prog[9] = I(5'd1, 5'd6, 5'd0, 5'd22); // exp→cache22
        prog_len = 10;
        send_program;
        repeat(70) @(posedge clk);

        $display("\n===== Basic op results (golden = LUT-emulated) =====");
        chk(20, 6.0,            0.1,  "EMUL 3*2");
        chk(21, b2r(G_SILU_1),  0.02, "SiLU(1.0)");
        chk(22, b2r(G_EXP_M2),  0.02, "exp(-2)");

        // ===== SFU test (via SRF) =====
        $display("\n===== SFU (rsqrt) =====");
        set_cache(10, r2b(4.0));
        prog[0] = I(5'd2, 5'd10, 5'd0, 5'd0);  // LDS cache10->SRF all
        prog[1] = I(5'd12, 5'd0, 5'd0, 5'd1);  // RSQRT SRF[0]→SRF[1]
        prog[2] = I(5'd3, 5'd0, 5'd0, 5'd30);  // St_scalar SRF→cache30
        prog_len = 3;
        send_program;
        repeat(40) @(posedge clk);
        chk(30, 4.0, 0.1, "Ld_sc SRF[0]");
        $display("  SRF[1]=rsqrt(4): cache30[1]=%.4f (golden %.4f)",
                 b2r(fake_cache[30][1*16+:16]), b2r(G_RSQRT_4));
        if (fake_cache[30][1*16+:16] !== G_RSQRT_4) begin
            errs=errs+1; $display("  FAIL rsqrt(4) bit-mismatch: %h != %h", fake_cache[30][1*16+:16], G_RSQRT_4);
        end

        // ========================================================
        //  RMSNorm full flow
        // ========================================================
        $display("\n========== RMSNorm ==========");
        set_rms_input;   // cache0=x, cache1=gamma, cache2=1/32
        set_rms_gold;

        prog[0]  = I(5'd0,  5'd0, 5'd0, 5'd0);  // Ld x→VRF0
        prog[1]  = I(5'd0,  5'd1, 5'd0, 5'd1);  // Ld gamma→VRF1
        prog[2]  = I(5'd2,  5'd2, 5'd0, 5'd0);  // LDS cache2->SRF all (SRF[0]=1/32)
        prog[3]  = I(5'd5,  5'd0, 5'd0, 5'd2);  // Square VRF0→VRF2
        prog[4]  = I(5'd16, 5'd2, 5'd0, 5'd1);  // Reduction VRF2→SRF1 (Σx²)
        prog[5]  = I(5'd15, 5'd1, 5'd0, 5'd2);  // Scalar_MUL SRF1*SRF0→SRF2 (mean)
        prog[6]  = I(5'd12, 5'd2, 5'd0, 5'd3);  // RSQRT SRF2→SRF3
        prog[7]  = I(5'd9,  5'd0, 5'd3, 5'd3);  // Scale_MUL VRF0 * SRF3→VRF3
        prog[8]  = I(5'd7,  5'd3, 5'd1, 5'd4);  // EMUL VRF3*VRF1(gamma)→VRF4
        prog[9]  = I(5'd1,  5'd4, 5'd0, 5'd28); // Store VRF4→cache28
        prog_len = 10;
        send_program;
        repeat(120) @(posedge clk);

        $display("RMSNorm result (cache28) vs golden  [golden = LUT-emulated pipeline]:");
        begin : rms_chk
            integer j; real got, gold, err, maxe; maxe=0;
            for(j=0;j<32;j=j+1) begin
                got = b2r(fake_cache[28][j*16+:16]);
                gold = b2r(rms_gold[j]);
                err = (got>gold)?got-gold:gold-got;
                if(err>maxe) maxe=err;
                $display("  lane%2d: HW=%9.4f (%016b)   golden=%9.4f   err=%.4f", j, got, fake_cache[28][j*16+:16], gold, err);
            end
            $display("  --------------------------------------------------");
            $display("  RMSNorm: 32 lanes, max_err=%.4f  [%s]", maxe, maxe<0.05?"PASS":"FAIL");
        end

        // ========================================================
        //  Softmax full flow
        // ========================================================
        $display("\n========== Softmax ==========");
        set_sm_input;   // cache3 = x (seed7)
        set_sm_gold;

        prog[0] = I(5'd0,  5'd3, 5'd0, 5'd0);  // Ld cache3→VRF0 (x)
        prog[1] = I(5'd17, 5'd0, 5'd0, 5'd0);  // Find_Max VRF0→SRF0
        prog[2] = I(5'd11, 5'd0, 5'd0, 5'd1);  // VS_SUB VRF0 - SRF0 → VRF1 (x-max)
        prog[3] = I(5'd6,  5'd1, 5'd0, 5'd2);  // Exp VRF1→VRF2
        prog[4] = I(5'd16, 5'd2, 5'd0, 5'd1);  // Reduction VRF2→SRF1 (Σexp)
        prog[5] = I(5'd13, 5'd1, 5'd0, 5'd2);  // 1/S SRF1→SRF2
        prog[6] = I(5'd9,  5'd2, 5'd2, 5'd3);  // Scale_MUL VRF2 * SRF2 → VRF3
        prog[7] = I(5'd1,  5'd3, 5'd0, 5'd29); // Store VRF3→cache29
        prog_len = 8;
        send_program;
        repeat(80) @(posedge clk);

        $display("Softmax result (cache29) vs golden  [golden = LUT-emulated pipeline]:");
        begin : sm_chk
            integer j; real got, gold, err, maxe, sumout; maxe=0; sumout=0;
            for(j=0;j<32;j=j+1) begin
                got = b2r(fake_cache[29][j*16+:16]);
                gold = b2r(sm_gold[j]);
                err = (got>gold)?got-gold:gold-got;
                if(err>maxe) maxe=err;
                sumout = sumout + got;
                $display("  lane%2d: HW=%9.4f (%016b)   golden=%9.4f   err=%.4f", j, got, fake_cache[29][j*16+:16], gold, err);
            end
            $display("  --------------------------------------------------");
            $display("  Softmax: 32 lanes, max_err=%.4f, sum=%.4f  [%s]", maxe, sumout, maxe<0.05?"PASS":"FAIL");
        end

        // ========================================================
        //  SiLU full flow (lane30/31 = ±5.0 → 클램프 경로)
        // ========================================================
        $display("\n========== SiLU (incl. clamp lanes 30/31 = -5/+5) ==========");
        set_silu_input;   // cache4 = x (seed11 + clamp cases)
        set_silu_gold;

        prog[0] = I(5'd0, 5'd4, 5'd0, 5'd0);   // Ld cache4->VRF0 (x)
        prog[1] = I(5'd4, 5'd0, 5'd0, 5'd1);   // SiLU VRF0->VRF1
        prog[2] = I(5'd1, 5'd1, 5'd0, 5'd27);  // Store VRF1->cache27
        prog_len = 3;
        send_program;
        repeat(40) @(posedge clk);

        $display("SiLU result (cache27) vs golden  [golden = LUT-emulated]:");
        begin : silu_chk
            integer j; real got, gold, err, maxe; maxe=0;
            for(j=0;j<32;j=j+1) begin
                got = b2r(fake_cache[27][j*16+:16]);
                gold = b2r(silu_gold[j]);
                err = (got>gold)?got-gold:gold-got;
                if(err>maxe) maxe=err;
                $display("  lane%2d: HW=%9.4f (%016b)   golden=%9.4f   err=%.4f", j, got, fake_cache[27][j*16+:16], gold, err);
            end
            $display("  --------------------------------------------------");
            $display("  SiLU: 32 lanes, max_err=%.4f  [%s]", maxe, maxe<0.05?"PASS":"FAIL");
        end

        // ===== 레이어 swap 확인: layer1 LUT 로 교체 후 SiLU 재실행 =====
        //   검증 2단: (1) 출력이 layer0 결과와 달라짐 (교체 반영)
        //             (2) layer1 LUT 기준 golden과 bit 일치 (교체 정확성)
        $display("\n========== LUT swap (silu layer1) ==========");
        set_silu_gold_l1;
        load_layer_luts(1, TB_EXP_IDX, TB_RSQRT_IDX, TB_RECIP_IDX);
        prog[0] = I(5'd4, 5'd0, 5'd0, 5'd1);   // SiLU VRF0->VRF1 (VRF0 유지됨)
        prog[1] = I(5'd1, 5'd1, 5'd0, 5'd26);  // Store VRF1->cache26
        prog_len = 2;
        send_program;
        repeat(40) @(posedge clk);
        begin : swap_chk
            integer j, diff, mism; diff=0; mism=0;
            for(j=0;j<32;j=j+1) begin
                if(fake_cache[26][j*16+:16] !== fake_cache[27][j*16+:16]) diff=diff+1;
                if(fake_cache[26][j*16+:16] !== silu_gold_l1[j]) begin
                    mism=mism+1;
                    $display("  lane%2d: HW=%h  golden(L1)=%h  MISMATCH", j, fake_cache[26][j*16+:16], silu_gold_l1[j]);
                end
            end
            $display("  layer0 vs layer1 output: %0d/32 lanes differ  [%s]",
                     diff, (diff>0)?"PASS (swap effective)":"FAIL (swap ignored)");
            $display("  layer1 golden bit-match: %0d/32 mismatch  [%s]",
                     mism, (mism==0)?"PASS (swap exact)":"FAIL");
            if(diff==0) errs=errs+1;
            if(mism>0)  errs=errs+1;
        end

        $display("\n===== %s (basic-op errs=%0d) =====", errs==0?"ALL BASIC PASS":"BASIC FAIL", errs);
        $finish;
    end
endmodule
