`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/18 19:17:38
// Design Name: 
// Module Name: BF16_ADD_MAX
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


module BF16_ADD_MAX (
    input  [15:0] A,
    input  [15:0] B,
    input         mode,        // 0=SUM, 1=MAX
    output [15:0] S
);
    wire        sa = A[15], sb = B[15];

    // ---- MAX 면 B 부호 반전(A-B), SUM 이면 그대로 ----
    wire [15:0] B_eff = mode ? {~B[15], B[14:0]} : B;

    // ================= BF16 가산 코어 (A + B_eff) =================
    wire        sx = A[15],   sy = B_eff[15];
    wire [7:0]  ea = A[14:7], ey = B_eff[14:7];
    wire [6:0]  ma = A[6:0],  my = B_eff[6:0];

    wire        a_zero = (ea == 8'd0);
    wire        y_zero = (ey == 8'd0);
    wire [7:0]  fa = a_zero ? 8'd0 : {1'b1, ma};
    wire [7:0]  fy = y_zero ? 8'd0 : {1'b1, my};

    wire        a_ge = (ea > ey) | ((ea == ey) & (ma >= my));
    wire [7:0]  e_big = a_ge ? ea : ey;
    wire [7:0]  e_sml = a_ge ? ey : ea;
    wire [7:0]  f_big = a_ge ? fa : fy;
    wire [7:0]  f_sml = a_ge ? fy : fa;
    wire        s_big = a_ge ? sx : sy;
    wire        s_sml = a_ge ? sy : sx;

    wire [7:0]  e_diff = e_big - e_sml;
    wire [10:0] f_big_ext = {f_big, 3'b000};
    wire [10:0] f_sml_pre = {f_sml, 3'b000};
    wire [10:0] f_sml_sh  = (e_diff >= 8'd11) ? 11'd0 : (f_sml_pre >> e_diff);
    wire        shifted_sticky = (e_diff >= 8'd11) ? (|f_sml_pre)
                               : (|(f_sml_pre & ((11'd1 << e_diff) - 11'd1)));
    wire [10:0] f_sml_ext = f_sml_sh | {10'b0, shifted_sticky};

    wire        same_sign = (s_big == s_sml);
    wire [11:0] sum_mag = same_sign ? ({1'b0, f_big_ext} + {1'b0, f_sml_ext})
                                    : ({1'b0, f_big_ext} - {1'b0, f_sml_ext});
    wire        s_out = s_big;

    reg  [10:0] norm_mant;
    reg  signed [9:0] exp_adj;
    reg  [3:0] lead;
    always @(*) begin
        if (same_sign) begin
            if (sum_mag[11]) begin
                norm_mant = {sum_mag[11:2], sum_mag[1] | sum_mag[0]};
                exp_adj   = 10'sd1;
            end else begin
                norm_mant = sum_mag[10:0];
                exp_adj   = 10'sd0;
            end
        end else begin
            lead = 4'd0;
            casez (sum_mag[10:0])
                11'b1??????????: lead = 4'd0;
                11'b01?????????: lead = 4'd1;
                11'b001????????: lead = 4'd2;
                11'b0001???????: lead = 4'd3;
                11'b00001??????: lead = 4'd4;
                11'b000001?????: lead = 4'd5;
                11'b0000001????: lead = 4'd6;
                11'b00000001???: lead = 4'd7;
                11'b000000001??: lead = 4'd8;
                11'b0000000001?: lead = 4'd9;
                11'b00000000001: lead = 4'd10;
                default:         lead = 4'd11;
            endcase
            norm_mant = sum_mag[10:0] << lead;
            exp_adj   = -$signed({6'b0, lead});
        end
    end

    wire signed [9:0] exp_n = $signed({2'b00, e_big}) + exp_adj;
    wire [6:0]  mant_n = norm_mant[9:3];
    wire        guard  = norm_mant[2];
    wire        rnd    = norm_mant[1];
    wire        stk    = norm_mant[0];
    wire        round_up = guard & (rnd | stk | mant_n[0]);
    wire [7:0]  mant_r = {1'b0, mant_n} + {7'b0, round_up};
    wire        round_carry = mant_r[7];
    wire [6:0]  mant_rf = round_carry ? 7'd0 : mant_r[6:0];
    wire signed [9:0] exp_rf = exp_n + (round_carry ? 10'sd1 : 10'sd0);

    wire        result_zero = (norm_mant == 11'd0);
    wire        underflow   = (exp_rf <= 0);
    wire        overflow    = (exp_rf >= 255);
    wire [7:0]  exp_out  = overflow ? 8'd255 : exp_rf[7:0];
    wire [6:0]  mant_out = overflow ? 7'd0 : mant_rf;
    wire        both_zero = a_zero & y_zero;

    wire [15:0] add_result = (both_zero | result_zero | underflow) ? 16'h0000
                           : {s_out, exp_out, mant_out};
    // ============================================================

    // ---- MAX 선택 ----
    //   부호 다름 : 양수(sign=0)인 쪽
    //   부호 같음 : A-B(=add_result) 부호로. add_result[15]=0 이면 A>=B → A
    wire        a_is_max = (sa != sb) ? (sa == 1'b0)
                         :              (~add_result[15]);
    wire [15:0] max_out = a_is_max ? A : B;

    // ---- 최종 출력 ----
    assign S = mode ? max_out : add_result;
endmodule