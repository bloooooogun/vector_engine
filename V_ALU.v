`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/17 16:20:54
// Design Name: 
// Module Name: V_ALU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module V_ALU #(
    parameter LANES=32
)
(
    input [LANES*16-1:0] VEC_IN1,
    input [LANES*16-1:0] VEC_IN2,
    input [LANES*16-1:0] VEC_IN3,
    input [1:0] CTRL_ALU_OP,
    input SQUARE_FLAG,
    output [LANES*16-1:0] VEC_OUT
    );
    genvar i;
    generate
        for (i=0; i<LANES; i=i+1) begin: LANE
            ALU_LANE u_LANE (
                .A(VEC_IN1[i*16 +: 16]),
                .X(VEC_IN2[i*16 +: 16]),
                .B(VEC_IN3[i*16 +: 16]),
                .CTRL_LANE_OP(CTRL_ALU_OP),
                .SQUARE_FLAG(SQUARE_FLAG),
                .Y(VEC_OUT[i*16 +: 16])
                );
        end
    endgenerate
    
endmodule
