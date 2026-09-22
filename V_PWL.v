`timescale 1ns / 1ps
//============================================================
// V_PWL - 32-lane non-uniform PWL (SiLU / exp)
//   v4: LUT_REGS 중앙 1벌 (함수 2개 x 208b) + lane별 SEG_SEL
//     line0 = SiLU, line1 = exp (레이어별 LDV로 swap)
//   출력: 계수 a/b (→ V_ALU madd) + x_eff (클램프 반영 x)
//============================================================
module V_PWL #(
    parameter LANES = 32
)(
    input                 clk,
    input                 rst_n,
    input                 pwl_op,          // 0=SiLU, 1=exp (전 lane 공통)
    input                 wr_en,
    input  [1:0]          wr_line,         // 라인(함수) 인덱스: 0/1만 사용
    input  [511:0]        wr_data,
    input  [LANES*16-1:0] x_vec,
    output [LANES*16-1:0] coeff_a_vec,
    output [LANES*16-1:0] coeff_b_vec,
    output [LANES*16-1:0] x_eff_vec,       // 클램프 반영 x (→ ALU x 입력)
    output [LANES-1:0]    lo_vec,          // lane별 하한 미달 플래그
    output [LANES-1:0]    hi_vec           // lane별 상한 초과 플래그
);
    wire [207:0] lut_bus;
    LUT_REGS u_lut (
        .clk(clk), .rst_n(rst_n),
        .wr_en(wr_en), .wr_sel(wr_line[0]), .wr_data(wr_data),
        .rd_sel(pwl_op), .lut_bus(lut_bus)
    );

    genvar i;
    generate
        for (i=0; i<LANES; i=i+1) begin : LANE
            SEG_SEL u_sel (
                .x       (x_vec[i*16 +: 16]),
                .lut_bus (lut_bus),
                .coeff_a (coeff_a_vec[i*16 +: 16]),
                .coeff_b (coeff_b_vec[i*16 +: 16]),
                .x_eff   (x_eff_vec[i*16 +: 16]),
                .out_lo  (lo_vec[i]),
                .out_hi  (hi_vec[i])
            );
        end
    endgenerate
endmodule
