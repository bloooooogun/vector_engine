`timescale 1ns / 1ps
//============================================================
// SEG_SEL - non-uniform 세그먼트 선택 (lane당 1개)
//   BF16_LT 비교기 5개 (comparator tree, N=4 세그먼트):
//     x <  x1        → seg0
//     x1 <= x < x2   → seg1
//     x2 <= x < x3   → seg2
//     x3 <= x        → seg3
//   범위 밖 클램프 (x_eff = ALU x 입력으로 대체):
//     x < x0 → x_eff = x0 (seg0 계수로 y(x0))
//     x > x4 → x_eff = x4 (seg3 계수로 y(x4))
//     그 외  → x_eff = x
//   lo/hi 플래그 출력: 함수별 범위 밖 정책은 상위(datapath)에서 결정
//     (exp/rsqrt/1_over_S = 끝점 연장(x_eff), SiLU = lo→0 / hi→x)
//============================================================
module SEG_SEL (
    input  [15:0]  x,
    input  [207:0] lut_bus,     // {word12..word0} = b3..b0, a3..a0, x4..x0
    output [15:0]  coeff_a,
    output [15:0]  coeff_b,
    output [15:0]  x_eff,
    output         out_lo,      // x < x0 (하한 미달)
    output         out_hi       // x > x4 (상한 초과)
);
    // ---- bus unpack ----
    wire [15:0] x0 = lut_bus[0*16 +: 16];
    wire [15:0] x1 = lut_bus[1*16 +: 16];
    wire [15:0] x2 = lut_bus[2*16 +: 16];
    wire [15:0] x3 = lut_bus[3*16 +: 16];
    wire [15:0] x4 = lut_bus[4*16 +: 16];
    wire [15:0] a0 = lut_bus[5*16 +: 16];
    wire [15:0] a1 = lut_bus[6*16 +: 16];
    wire [15:0] a2 = lut_bus[7*16 +: 16];
    wire [15:0] a3 = lut_bus[8*16 +: 16];
    wire [15:0] b0 = lut_bus[9*16 +: 16];
    wire [15:0] b1 = lut_bus[10*16 +: 16];
    wire [15:0] b2 = lut_bus[11*16 +: 16];
    wire [15:0] b3 = lut_bus[12*16 +: 16];

    // ---- BF16_LT 비교기 5개 (병렬) ----
    wire lo, lt1, lt2, lt3, hi;
    BF16_LT u_lt_x0 (.A(x),  .B(x0), .LT(lo));   // 하한 미달
    BF16_LT u_lt_x1 (.A(x),  .B(x1), .LT(lt1));
    BF16_LT u_lt_x2 (.A(x),  .B(x2), .LT(lt2));
    BF16_LT u_lt_x3 (.A(x),  .B(x3), .LT(lt3));
    BF16_LT u_gt_x4 (.A(x4), .B(x),  .LT(hi));   // 상한 초과 (x4 < x)

    // ---- 세그먼트 선택 (클램프 시 경계 세그먼트) ----
    wire [1:0] seg = lt1 ? 2'd0 :
                     lt2 ? 2'd1 :
                     lt3 ? 2'd2 : 2'd3;

    assign coeff_a = (seg==2'd0) ? a0 : (seg==2'd1) ? a1 : (seg==2'd2) ? a2 : a3;
    assign coeff_b = (seg==2'd0) ? b0 : (seg==2'd1) ? b1 : (seg==2'd2) ? b2 : b3;
    assign x_eff   = lo ? x0 : hi ? x4 : x;
    assign out_lo  = lo;
    assign out_hi  = hi;
endmodule
