`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/17 16:26:28
// Design Name: 
// Module Name: ALU_LANE
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


module ALU_LANE(  // AX+B = Y
    input  [15:0] A, X, B,
    input  [1:0]  CTRL_LANE_OP,
    input         SQUARE_FLAG,
    output [15:0] Y
    );
    localparam OP_MUL=2'd0, OP_ADD=2'd1, OP_SUB=2'd2, OP_MADD=2'd3;

    wire [15:0] MINUS_X = {~X[15], X[14:0]};
    wire [15:0] MUL_A, MUL_B, MUL_P, ADD_A, ADD_B, ADD_S;

    // ── 곱셈기 입력 ──
    assign MUL_A = A;
    assign MUL_B = SQUARE_FLAG ? A : X;     // square면 A·A, 아니면 A·X

    // ── 가산기 입력 ──
    assign ADD_A = (CTRL_LANE_OP == OP_MADD) ? MUL_P : A;
    assign ADD_B = (CTRL_LANE_OP == OP_MADD) ? B :
                   (CTRL_LANE_OP == OP_SUB)  ? MINUS_X : X;

    BF16_MUL u_mul (.A(MUL_A), .B(MUL_B), .P(MUL_P));
    BF16_ADD u_add (.A(ADD_A), .B(ADD_B), .S(ADD_S));

    assign Y = (CTRL_LANE_OP == OP_MUL) ? MUL_P : ADD_S;
endmodule
