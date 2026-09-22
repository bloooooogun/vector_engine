`timescale 1ns / 1ps
//============================================================
// BF16_LT - BF16 크기 비교 primitive (LT = A < B)
//   부동소수점 연산 불필요: BF16은 sign-magnitude 순서 보존
//     부호 다름       → 음수 쪽이 작음 (단 ±0 == ±0)
//     둘 다 양수      → magnitude[14:0] 정수 비교
//     둘 다 음수      → magnitude 비교 반전
//   NaN/Inf 미고려 (엔진 전체 동일 정책)
//============================================================
module BF16_LT (
    input  [15:0] A,
    input  [15:0] B,
    output        LT        // A < B
);
    wire        sa = A[15], sb = B[15];
    wire [14:0] ma = A[14:0], mb = B[14:0];
    wire        za = (ma == 15'd0), zb = (mb == 15'd0);   // ±0

    assign LT = (za && zb) ? 1'b0 :            // ±0 == ±0
                (sa != sb) ? sa   :            // 음수 < 양수
                sa         ? (ma > mb) :       // 둘 다 음수: |큰|쪽이 작음
                             (ma < mb);        // 둘 다 양수
endmodule
