`timescale 1ns / 1ps
//============================================================
// LUT_REGS - non-uniform LUT 저장 (함수 2개 x 208b)
//   함수당 512b 캐시 라인 1개로 교체 (레이어별 swap 대응):
//     word[0..4]  = x0..x4  (knot 5개, 오름차순)
//     word[5..8]  = a0..a3  (세그먼트 slope)
//     word[9..12] = b0..b3  (세그먼트 intercept)
//     word[13..31] = 미사용
//   중앙 1벌 저장, 판독은 조합 (전 lane broadcast)
//============================================================
module LUT_REGS (
    input          clk, rst_n,
    input          wr_en,
    input          wr_sel,          // 라인(함수) 선택: 0/1
    input  [511:0] wr_data,
    input          rd_sel,          // 판독 함수 선택 (pwl_op / sfu_op)
    output [207:0] lut_bus          // {b3..b0, a3..a0, x4..x0} word-order [j*16+:16]
);
    reg [207:0] lut [0:1];
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            lut[0] <= 208'd0;
            lut[1] <= 208'd0;
        end else if (wr_en)
            lut[wr_sel] <= wr_data[207:0];
    end
    assign lut_bus = lut[rd_sel];
endmodule
