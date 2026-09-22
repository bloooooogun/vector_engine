`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/18 19:16:03
// Design Name: 
// Module Name: REDUCE
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


module REDUCE #(
    parameter LANES = 32
)(
    input  [LANES*16-1:0] vec_in,
    input                 red_op,   // 0=SUM, 1=MAX
    output [15:0]         y
);
    wire [15:0] s5 [0:31];
    wire [15:0] s4 [0:15];
    wire [15:0] s3 [0:7];
    wire [15:0] s2 [0:3];
    wire [15:0] s1 [0:1];

    genvar i;
    generate
        for (i=0;i<32;i=i+1) begin assign s5[i] = vec_in[i*16 +: 16]; end
        for (i=0;i<16;i=i+1) begin : ST4
            BF16_ADD_MAX u(.A(s5[2*i]), .B(s5[2*i+1]), .mode(red_op), .S(s4[i]));
        end
        for (i=0;i<8;i=i+1) begin : ST3
            BF16_ADD_MAX u(.A(s4[2*i]), .B(s4[2*i+1]), .mode(red_op), .S(s3[i]));
        end
        for (i=0;i<4;i=i+1) begin : ST2
            BF16_ADD_MAX u(.A(s3[2*i]), .B(s3[2*i+1]), .mode(red_op), .S(s2[i]));
        end
        for (i=0;i<2;i=i+1) begin : ST1
            BF16_ADD_MAX u(.A(s2[2*i]), .B(s2[2*i+1]), .mode(red_op), .S(s1[i]));
        end
    endgenerate
    BF16_ADD_MAX uf(.A(s1[0]), .B(s1[1]), .mode(red_op), .S(y));
endmodule
