`timescale 1ns / 1ps
//============================================================
// SALU - scalar ALU (add/sub/mul/max/madd)
//   BF16_MUL + BF16_ADD_MAX 조합
//     add  (000): ADD_MAX(A, B, 0)
//     sub  (001): ADD_MAX(A, -B, 0)
//     mul  (010): MUL(A, B)
//     max  (011): ADD_MAX(A, B, 1)
//     madd (100): ADD_MAX(MUL(A,B), C, 0)  = A*B + C
//============================================================
module SALU (
    input  [15:0] A,        // operand1 / madd a
    input  [15:0] B,        // operand2 / madd x
    input  [15:0] C,        // madd 가산항 b (add/sub/mul/max 시 무시)
    input  [2:0]  salu_op,  // 000 add/001 sub/010 mul/011 max/100 madd
    output [15:0] S
);
    wire is_madd = (salu_op == 3'b100);
    wire is_mul  = (salu_op == 3'b010);
    wire is_sub  = (salu_op == 3'b001);
    wire is_max  = (salu_op == 3'b011);

    // MUL (mul / madd)
    wire [15:0] mul_out;
    BF16_MUL u_mul (.A(A), .B(B), .P(mul_out));

    // ADD_MAX 입력 mux
    wire [15:0] B_eff   = is_sub ? {~B[15], B[14:0]} : B;  // sub: -B
    wire [15:0] addmax_A = is_madd ? mul_out : A;
    wire [15:0] addmax_B = is_madd ? C       : B_eff;
    wire        addmax_mode = is_max;                       // max만 mode=1
    wire [15:0] addmax_out;
    BF16_ADD_MAX u_addmax (.A(addmax_A), .B(addmax_B), .mode(addmax_mode), .S(addmax_out));

    // 출력: mul만 mul_out, 나머지 addmax_out
    assign S = is_mul ? mul_out : addmax_out;
endmodule