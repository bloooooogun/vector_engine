`timescale 1ns / 1ps
//============================================================
// SCALAR_DATAPATH - scalar 구획 (SALU + S_PWL + acc_buffer)
//   VEC_DATAPATH 의 scalar 버전. 모든 데이터 SRF 경유. 출력 등록.
//
//   ACC_MODE:
//     SALU(00) : srf_rd1 op srf_rd2
//     ACCUM(01): acc_buf op srf_rd1 → acc_buf (축적) / flush 시 배출
//     SFU(10)  : a*x_eff+b (rsqrt / 1_over_S), S_PWL 계수 → SALU madd
//
//   v4: non-uniform PWL
//     - SFU x 입력 = x_eff (범위 밖 클램프: 경계 knot 대입)
//     - v3의 sat_lo/sat_hi 포화 상수 삭제 (클램프가 대체)
//============================================================
module SCALAR_DATAPATH (
    input  clk, rst_n,
    input  [15:0]  srf_rd1,        // operand A / 누적 입력 / SFU x
    input  [15:0]  srf_rd2,        // operand B
    input  [1:0]   ACC_MODE,       // SALU=00 / ACCUM=01 / SFU=10
    input  [2:0]   salu_op,        // add/sub/mul/max/madd (SALU 모드)
    input          acc_op,         // ACCUM 누적: add=0 / max=1
    input          sfu_op,         // 0=rsqrt, 1=1/S(recip)
    input          acc_flush,      // ACCUM: 0=축적, 1=배출+clear
    input          coeff_wr_en,
    input  [1:0]   coeff_wr_line,  // 함수 라인: 0=rsqrt, 1=1/S
    input  [511:0] coeff_wr_data,  // 캐시 라인 데이터 (LUT 1벌)
    output reg [15:0] result_scalar
);
    localparam M_SALU=2'b00, M_ACCUM=2'b01, M_SFU=2'b10;
    localparam OP_ADD=3'b000, OP_MAX=3'b011, OP_MADD=3'b100;

    reg [15:0] acc_buf;   // 누적 피드백 레지스터

    // ---- S_PWL: 계수 + x_eff 인출 (A 방식) ----
    wire [15:0] coeff_a, coeff_b, sfu_x_eff;
    S_PWL u_s_pwl (
        .clk(clk), .rst_n(rst_n),
        .wr_en(coeff_wr_en), .wr_line(coeff_wr_line), .wr_data(coeff_wr_data),
        .BF16_x(srf_rd1), .sfu_op(sfu_op),
        .coeff_a(coeff_a), .coeff_b(coeff_b), .x_eff(sfu_x_eff)
    );

    // ---- SALU 입력 라우팅 (ACC_MODE) ----
    //   ACCUM: A=acc_buf, B=srf_rd1, op=acc_op(add/max)
    //   SALU : A=srf_rd1, B=srf_rd2, op=salu_op
    //   SFU  : A=coeff_a, B=x_eff(클램프 반영), C=coeff_b, op=madd
    wire [15:0] salu_A = (ACC_MODE==M_ACCUM) ? acc_buf :
                         (ACC_MODE==M_SFU)   ? coeff_a : srf_rd1;
    wire [15:0] salu_B = (ACC_MODE==M_ACCUM) ? srf_rd1 :
                         (ACC_MODE==M_SFU)   ? sfu_x_eff : srf_rd2;
    wire [15:0] salu_C = coeff_b;   // SFU madd 가산항
    wire [2:0]  salu_op_eff = (ACC_MODE==M_ACCUM) ? (acc_op ? OP_MAX : OP_ADD) :
                              (ACC_MODE==M_SFU)   ? OP_MADD : salu_op;

    wire [15:0] salu_out;
    SALU u_salu (.A(salu_A), .B(salu_B), .C(salu_C), .salu_op(salu_op_eff), .S(salu_out));

    // ---- acc_buffer 갱신 + 출력 등록 ----
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            acc_buf       <= 16'h0;
            result_scalar <= 16'h0;
        end else begin
            // ACCUM 모드 acc_buffer 관리
            if (ACC_MODE==M_ACCUM) begin
                if (acc_flush) acc_buf <= 16'h0;       // 배출하며 clear
                else           acc_buf <= salu_out;     // 축적
            end
            // 출력: ACCUM flush면 acc_buf 배출, 그 외 salu_out
            result_scalar <= (ACC_MODE==M_ACCUM && acc_flush) ? acc_buf : salu_out;
        end
    end
endmodule
