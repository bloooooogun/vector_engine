//============================================================
// BF16_ADD.v
//
// 작성 목적:
//   BF16 가산기. S = A + B. RNE + FTZ.
//   PWL 의 (a*x) + b 합산용.
//
// HW 관점 동작 흐름:
//   1) 지수 비교 -> 큰 쪽 기준, 작은 쪽 가수를 차이만큼 우시프트(정렬)
//   2) 부호 같으면 가수 가산, 다르면 감산(큰 절댓값 - 작은 절댓값)
//   3) 정규화: 가산 자리올림 -> 우시프트 / 감산 선행0 -> 좌시프트
//   4) RNE 라운딩, FTZ
//
// 단순화 전제:
//   - 입력 subnormal 은 FTZ (exp=0 -> 0 취급)
//   - guard/round/sticky 3비트 유지로 RNE
//============================================================
module BF16_ADD (
    input  [15:0] A,
    input  [15:0] B,
    output [15:0] S
);

    // ---- 분해 ----
    wire        sa = A[15],   sb = B[15];
    wire [7:0]  ea = A[14:7], eb = B[14:7];
    wire [6:0]  ma = A[6:0],  mb = B[6:0];

    wire        a_zero = (ea == 8'd0);   // FTZ: subnormal/zero
    wire        b_zero = (eb == 8'd0);

    // hidden bit 부착 (8b: 1.fffffff). FTZ 면 0.
    wire [7:0]  fa = a_zero ? 8'd0 : {1'b1, ma};
    wire [7:0]  fb = b_zero ? 8'd0 : {1'b1, mb};

    // ---- 큰 쪽 선택 (지수, 같으면 가수로) ----
    wire        a_ge = (ea > eb) | ((ea == eb) & (ma >= mb));

    wire [7:0]  e_big = a_ge ? ea : eb;
    wire [7:0]  e_sml = a_ge ? eb : ea;
    wire [7:0]  f_big = a_ge ? fa : fb;
    wire [7:0]  f_sml = a_ge ? fb : fa;
    wire        s_big = a_ge ? sa : sb;
    wire        s_sml = a_ge ? sb : sa;

    // ---- 지수 차 만큼 작은 가수 우시프트 (guard/round/sticky 확보) ----
    // 가수를 3비트 확장(GRS)한 폭에서 시프트
    wire [7:0]  e_diff = e_big - e_sml;
    // 11비트: [10:3]=가수8b, [2:0]=GRS
    wire [10:0] f_big_ext = {f_big, 3'b000};
    wire [10:0] f_sml_pre = {f_sml, 3'b000};
    // 시프트 (>=11 이면 전부 sticky 로 흡수)
    wire [10:0] f_sml_sh  = (e_diff >= 8'd11) ? 11'd0 : (f_sml_pre >> e_diff);
    // 시프트로 밀려난 비트 sticky 보존
    wire        shifted_sticky = (e_diff >= 8'd11) ? (|f_sml_pre)
                               : (|(f_sml_pre & ((11'd1 << e_diff) - 11'd1)));
    wire [10:0] f_sml_ext = f_sml_sh | {10'b0, shifted_sticky};

    // ---- 부호 동일? ----
    wire        same_sign = (s_big == s_sml);

    // ---- 가산 or 감산 ----
    wire [11:0] sum_mag = same_sign ? ({1'b0, f_big_ext} + {1'b0, f_sml_ext})
                                    : ({1'b0, f_big_ext} - {1'b0, f_sml_ext});

    wire        s_out = s_big;   // 큰 쪽 부호

    // ---- 정규화 ----
    // 가산: sum_mag[11] 자리올림 가능 -> 우시프트 1, exp+1
    // 감산: 선행0 만큼 좌시프트, exp 감소
    reg  [10:0] norm_mant;
    reg  signed [9:0] exp_adj;
    integer i;
    reg [3:0] lead;
    always @(*) begin
        if (same_sign) begin
            if (sum_mag[11]) begin
                // 우시프트: 밀려나는 최하위비트(sum_mag[0])를 sticky로 보존
                norm_mant = {sum_mag[11:2], sum_mag[1] | sum_mag[0]};
                exp_adj   = 10'sd1;
            end else begin
                norm_mant = sum_mag[10:0];
                exp_adj   = 10'sd0;
            end
        end else begin
            // 감산: sum_mag[10:0] 에서 선행0 카운트
            lead = 4'd0;
            // 최상위(비트10)부터 1 찾기
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
                default:         lead = 4'd11;  // 완전 0
            endcase
            norm_mant = sum_mag[10:0] << lead;
            exp_adj   = -$signed({6'b0, lead});
        end
    end

    wire signed [9:0] exp_n = $signed({2'b00, e_big}) + exp_adj;

    // ---- 라운딩 (norm_mant: [10:3]=가수8b(hidden 포함), [2:0]=GRS) ----
    wire [6:0]  mant_n = norm_mant[9:3];   // hidden 제외 7b
    wire        guard  = norm_mant[2];
    wire        rnd    = norm_mant[1];
    wire        stk    = norm_mant[0];
    wire        round_up = guard & (rnd | stk | mant_n[0]);

    wire [7:0]  mant_r = {1'b0, mant_n} + {7'b0, round_up};
    wire        round_carry = mant_r[7];
    wire [6:0]  mant_rf = round_carry ? 7'd0 : mant_r[6:0];
    wire signed [9:0] exp_rf = exp_n + (round_carry ? 10'sd1 : 10'sd0);

    // ---- 예외 ----
    wire        result_zero = (norm_mant == 11'd0);          // 완전 상쇄
    wire        underflow   = (exp_rf <= 0);                 // FTZ
    wire        overflow    = (exp_rf >= 255);
    wire [7:0]  exp_out  = overflow ? 8'd255 : exp_rf[7:0];
    wire [6:0]  mant_out = overflow ? 7'd0 : mant_rf;

    // 양쪽 다 0 입력이면 0
    wire        both_zero = a_zero & b_zero;

    assign S = (both_zero | result_zero | underflow) ? 16'h0000
             : {s_out, exp_out, mant_out};

endmodule
