`timescale 1ns / 1ps
//============================================================
// S_PWL - scalar non-uniform PWL (rsqrt / 1_over_S)
//   v4: LUT_REGS (함수 2개) + SEG_SEL 1개 (V_PWL의 scalar판)
//     line0 = rsqrt, line1 = 1/S (recip)  — 레이어별 LDV로 swap
//   A 방식 유지: 계수 a,b 인출 + x_eff, MADD 는 SALU 공유
//   v3의 log-scale decoder / 포화 상수 삭제 — 클램프는 x_eff 로 처리
//============================================================
module S_PWL (
    input          clk, rst_n,
    input          wr_en,
    input  [1:0]   wr_line,        // 라인(함수) 인덱스: 0/1만 사용
    input  [511:0] wr_data,
    input  [15:0]  BF16_x,
    input          sfu_op,         // 0=rsqrt, 1=1/S(recip)
    output [15:0]  coeff_a,        // → SALU madd A
    output [15:0]  coeff_b,        // → SALU madd C
    output [15:0]  x_eff           // → SALU madd B (클램프 반영 x)
);
    wire [207:0] lut_bus;
    LUT_REGS u_lut (
        .clk(clk), .rst_n(rst_n),
        .wr_en(wr_en), .wr_sel(wr_line[0]), .wr_data(wr_data),
        .rd_sel(sfu_op), .lut_bus(lut_bus)
    );
    SEG_SEL u_sel (
        .x(BF16_x), .lut_bus(lut_bus),
        .coeff_a(coeff_a), .coeff_b(coeff_b), .x_eff(x_eff),
        .out_lo(), .out_hi()   // rsqrt/1_over_S 는 끝점 연장 — 플래그 미사용
    );
endmodule
