`timescale 1ns/1ps
//============================================================
// tb_rope_v5 - RoPE 회전 실행 TB (post-synth safe)
//
//   호스트가 cos/sin 을 사전계산해 캐시에 둔 상태를 모사.
//   d=128 → VRF 4엔트리. 그룹 A=(E0,E2), B=(E1,E3).
//   cos/sin 은 d/2 개만 (cos[j+64]=cos[j])
//
//   VRF 배치 (뱅크 충돌 회피: Q/임시는 짝수, cos/sin 은 홀수)
//     E0=0  E1=2  E2=4  E3=6      (Q 입력,   bank0)
//     CA=1  CB=3  SA=5  SB=7      (cos/sin,  bank1)
//     T1=8 (bank0)  T2=9 (bank1)  (임시)
//     O0=10 O1=12 O2=14 O3=16     (출력,     bank0)
//
//   그룹당 6명령 (옵션 X: ESUB 사용, 신규 게이트 0)
//     T1 = EMUL(Q_lo, cos) ; T2 = EMUL(Q_hi, sin) ; O_lo = ESUB(T1,T2)
//     T1 = EMUL(Q_hi, cos) ; T2 = EMUL(Q_lo, sin) ; O_hi = EADD(T1,T2)
//============================================================
module tb_rope_v5;
    reg clk, rst_n;
    reg [19:0] instr_in; reg enq_valid; wire enq_ready;
    wire cache_req, cache_we; wire [31:0] cache_addr;
    wire [511:0] cache_wdata; reg [511:0] cache_rdata_r; reg cache_valid;

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

    `include "rope_data.vh"

    // opcode
    localparam LDV=5'd0, STV=5'd1, EMUL=5'd7, EADD=5'd8, ESUB=5'd18;
    // VRF 배치
    localparam E0=5'd0, E1=5'd2, E2=5'd4, E3=5'd6;
    localparam CA=5'd1, CB=5'd3, SA=5'd5, SB=5'd7;
    localparam T1=5'd8, T2=5'd9;
    localparam O0=5'd10, O1=5'd12, O2=5'd14, O3=5'd16;

    integer j, mism_g, mism_t; real err, maxe, maxt;
    real nin, nout, nerr;

    initial begin
        clk=0; rst_n=0; enq_valid=0; instr_in=0; cache_valid=0;
        set_rope_input; set_rope_gold;
        #12; rst_n=1;

        //===== 1. 로드: Q 4엔트리 + cos 2 + sin 2 =====
        $display("===== RoPE (d=%0d) — load =====", ROPE_D);
        prog[0]=I(LDV, 5'd0,  5'd0, E0);   // Q[0:32]
        prog[1]=I(LDV, 5'd1,  5'd0, E1);   // Q[32:64]
        prog[2]=I(LDV, 5'd2,  5'd0, E2);   // Q[64:96]
        prog[3]=I(LDV, 5'd3,  5'd0, E3);   // Q[96:128]
        prog[4]=I(LDV, 5'd8,  5'd0, CA);   // cos[0:32]
        prog[5]=I(LDV, 5'd9,  5'd0, CB);   // cos[32:64]
        prog[6]=I(LDV, 5'd10, 5'd0, SA);   // sin[0:32]
        prog[7]=I(LDV, 5'd11, 5'd0, SB);   // sin[32:64]
        prog_len=8; send_program; repeat(50) @(posedge clk);

        //===== 2. 회전: 그룹 A (j=0..31) =====
        $display("===== rotate group A (j=0..31) =====");
        prog[0]=I(EMUL, E0, CA, T1);   // Q_lo · cos
        prog[1]=I(EMUL, E2, SA, T2);   // Q_hi · sin
        prog[2]=I(ESUB, T1, T2, O0);   // Q'_lo = Q_lo·cos − Q_hi·sin
        prog[3]=I(EMUL, E2, CA, T1);   // Q_hi · cos
        prog[4]=I(EMUL, E0, SA, T2);   // Q_lo · sin
        prog[5]=I(EADD, T1, T2, O2);   // Q'_hi = Q_hi·cos + Q_lo·sin
        prog_len=6; send_program; repeat(45) @(posedge clk);

        //===== 3. 회전: 그룹 B (j=32..63) =====
        $display("===== rotate group B (j=32..63) =====");
        prog[0]=I(EMUL, E1, CB, T1);
        prog[1]=I(EMUL, E3, SB, T2);
        prog[2]=I(ESUB, T1, T2, O1);
        prog[3]=I(EMUL, E3, CB, T1);
        prog[4]=I(EMUL, E1, SB, T2);
        prog[5]=I(EADD, T1, T2, O3);
        prog_len=6; send_program; repeat(45) @(posedge clk);

        //===== 4. 저장: 캐시 20~23 =====
        prog[0]=I(STV, O0, 5'd0, 5'd20);
        prog[1]=I(STV, O1, 5'd0, 5'd21);
        prog[2]=I(STV, O2, 5'd0, 5'd22);
        prog[3]=I(STV, O3, 5'd0, 5'd23);
        prog_len=4; send_program; repeat(40) @(posedge clk);

        //===== 5. 검증 =====
        $display("\n===== 결과 (HW vs golden vs 진값) =====");
        $display("  %4s %10s %10s %10s %10s %10s", "j", "Q[j]", "HW", "golden", "true", "|HW-true|");
        mism_g=0; mism_t=0; maxe=0.0; maxt=0.0;
        for(j=0;j<ROPE_D;j=j+1) begin : chk
            reg [15:0] hw, qi;
            hw = fake_cache[20 + (j/32)][ (j%32)*16 +: 16 ];
            qi = fake_cache[j/32][ (j%32)*16 +: 16 ];
            err = b2r(hw) - b2r(rope_true[j]); if(err<0) err=-err;
            if(err>maxt) maxt=err;
            if(hw !== rope_gold[j]) begin
                mism_g=mism_g+1;
                $display("  %4d %10.5f %10.5f %10.5f %10.5f %10.2e  <-- GOLDEN MISMATCH",
                         j, b2r(qi), b2r(hw), b2r(rope_gold[j]), b2r(rope_true[j]), err);
            end else if (j<8 || j==64 || j==65) begin
                $display("  %4d %10.5f %10.5f %10.5f %10.5f %10.2e", j,
                         b2r(qi), b2r(hw), b2r(rope_gold[j]), b2r(rope_true[j]), err);
            end
        end
        $display("  ... (전 %0d 항목 검사)", ROPE_D);

        //===== 6. 회전 불변량: |Q'| == |Q| =====
        $display("\n===== 회전 불변량 검사  |(Q'[j],Q'[j+d/2])| == |(Q[j],Q[j+d/2])| =====");
        nerr=0.0;
        for(j=0;j<ROPE_D/2;j=j+1) begin : nchk
            reg [15:0] qa,qb,oa,ob; real d1,d2;
            qa = fake_cache[j/32][(j%32)*16 +: 16];
            qb = fake_cache[(j+ROPE_D/2)/32][((j+ROPE_D/2)%32)*16 +: 16];
            oa = fake_cache[20+(j/32)][(j%32)*16 +: 16];
            ob = fake_cache[20+((j+ROPE_D/2)/32)][((j+ROPE_D/2)%32)*16 +: 16];
            d1 = b2r(qa)*b2r(qa) + b2r(qb)*b2r(qb);
            d2 = b2r(oa)*b2r(oa) + b2r(ob)*b2r(ob);
            err = d1-d2; if(err<0) err=-err;
            if(err>nerr) nerr=err;
        end
        $display("  max |‖Q'‖² − ‖Q‖²| = %.3e   (회전이면 0, BF16 오차만 남아야 함)", nerr);

        $display("\n===== 종합 =====");
        $display("  golden bit 일치 : %0d/%0d mismatch  [%s]",
                 mism_g, ROPE_D, mism_g==0 ? "PASS (bit-exact)" : "FAIL");
        $display("  진값 대비 최대오차: %.3e", maxt);
        $display("  회전 불변량      : %.3e", nerr);
        $display("  %s", mism_g==0 ? "===== ROPE PASS =====" : "===== ROPE FAIL =====");
        $finish;
    end
endmodule
