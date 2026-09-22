//============================================================
// BF16_MUL.v
//
// 작성 목적:
//   BF16 곱셈기. P = A * B.
//   round-to-nearest-even(RNE) + FTZ (subnormal 입출력 0 처리).
//   PyTorch BF16(RNE) 참조모델과 정합 목적.
//
// BF16 포맷: [15]=sign, [14:7]=exp(bias 127), [6:0]=mant(7b)
//
// HW 관점 동작 흐름:
//   1) 부호: 두 입력 부호 XOR (배선)
//   2) 지수: exp_a + exp_b - 127 (가산기)
//   3) 가수: 1.f 형태(8b) 끼리 곱 (8x8 = 16b 부분곱 합)
//   4) 정규화: 곱 결과 최상위가 비트15(2.0~) 면 1비트 우시프트 후 exp+1
//   5) 라운딩: 버려지는 하위비트로 RNE
//   6) FTZ: 결과 지수 <=0 (언더플로) -> 0,  입력에 subnormal/zero -> 0
//============================================================
module BF16_MUL (
    input  [15:0] A,
    input  [15:0] B,
    output [15:0] P
);

    // ---- 필드 분해 ----
    wire        sa = A[15],   sb = B[15];
    wire [7:0]  ea = A[14:7], eb = B[14:7];
    wire [6:0]  ma = A[6:0],  mb = B[6:0];

    // ---- FTZ: 입력이 0 또는 subnormal(exp=0) 이면 결과 0 ----
    wire        a_zero = (ea == 8'd0);
    wire        b_zero = (eb == 8'd0);
    wire        any_zero = a_zero | b_zero;

    // ---- 부호 ----
    wire        sp = sa ^ sb;

    // ---- 가수에 hidden bit 부착: 1.fffffff (8비트) ----
    wire [7:0]  fa = {1'b1, ma};
    wire [7:0]  fb = {1'b1, mb};

    // ---- 가수 곱: 8b x 8b = 16b ----
    // 입력이 [1.0,2.0) 이므로 곱은 [1.0,4.0) -> 비트[15] 또는 [14] 가 선두
    wire [15:0] prod = fa * fb;

    // ---- 지수 합 (bias 한 번 빼기) ----
    // 임시로 넓게 잡아 언더/오버 판정
    wire signed [9:0] exp_sum = $signed({2'b00, ea}) + $signed({2'b00, eb}) - 10'sd127;

    // ---- 정규화 ----
    // prod[15]=1 이면 결과는 1x.xxxx (>=2.0) -> exp+1, 상위 8비트 사용
    // prod[15]=0 이면 prod[14]=1 (1.xxxx) -> 그대로
    wire              ovf = prod[15];
    wire signed [9:0] exp_n = ovf ? (exp_sum + 10'sd1) : exp_sum;

    // 정규화된 가수: hidden bit 제외한 7비트 + 라운딩용 하위비트
    // ovf=1: prod[14:8] 이 mantissa, prod[7:0] 이 잔여
    // ovf=0: prod[13:7] 이 mantissa, prod[6:0] 이 잔여
    wire [6:0]  mant_n = ovf ? prod[14:8] : prod[13:7];
    wire        guard  = ovf ? prod[7]    : prod[6];   // round bit
    wire        sticky = ovf ? (|prod[6:0]) : (|prod[5:0]);

    // ---- RNE: guard=1 && (sticky=1 || mant_n LSB=1) 이면 +1 ----
    wire        round_up = guard & (sticky | mant_n[0]);
    wire [7:0]  mant_r = {1'b0, mant_n} + {7'b0, round_up};
    // 라운딩 자리올림으로 8비트째 set 되면 exp +1, mantissa 0
    wire        round_carry = mant_r[7];
    wire [6:0]  mant_final = round_carry ? 7'd0 : mant_r[6:0];
    wire signed [9:0] exp_final = exp_n + (round_carry ? 10'sd1 : 10'sd0);

    // ---- 출력 조립 + 예외 ----
    wire        underflow = (exp_final <= 0);          // FTZ
    wire        overflow  = (exp_final >= 255);        // Inf 포화
    wire [7:0]  exp_out = overflow ? 8'd255 : exp_final[7:0];
    wire [6:0]  mant_out = overflow ? 7'd0 : mant_final;

    assign P = (any_zero | underflow) ? 16'h0000             // FTZ -> +0 (torch 정합)
             :                          {sp, exp_out, mant_out};

endmodule
