`timescale 1ns / 1ps
//============================================================
// VECTOR_ENGINE - 비선형 전담 벡터 엔진 (TOP)
//   내부 결선: INSTR_FIFO + OP_CONTROL + VRF/SRF + VEC/SCALAR_DATAPATH + VEC_LSU
//   외부: 명령 입력(enq) + 캐시 인터페이스
//   single in-flight
//
//   v4: non-uniform LUT (knot+계수 512b 라인 1개/함수, 레이어별 swap)
//     (LDV 목적지 공간: src2[0]=1 → LUT_REGS 라인 write)
//============================================================
module VECTOR_ENGINE (
    input         clk, rst_n,
    // 명령 입력 (→ INSTR_FIFO enq)
    input  [19:0] instr_in,
    input         enq_valid,
    output        enq_ready,
    // 캐시 인터페이스
    output        cache_req,
    output        cache_we,
    output [31:0] cache_addr,
    output [511:0] cache_wdata,
    input  [511:0] cache_rdata,
    input         cache_valid
);
    // ---- FIFO ↔ OP_CONTROL ----
    wire [19:0] instr_out;
    wire        deq_valid, deq_ready;

    // ---- OP_CONTROL 출력 ----
    wire vrf_rd1_re,vrf_rd2_re,vrf_wr_en,vrf_wr_sel, srf_rd1_re,srf_rd2_re,srf_wr_en,srf_cache_wr_en;
    wire [4:0] vrf_rd1_addr,vrf_rd2_addr,vrf_wr_addr, srf_rd1_addr,srf_rd2_addr,srf_wr_addr;
    wire [1:0] vec_mode,vec_alu_op,accum_mode; wire [2:0] acc_salu_op;
    wire vec_sq,vec_pwl_op,vec_red_op, acc_op,acc_sfu_op,acc_flush, wr_sel;
    wire [1:0] lsu_op;
    wire pwl_coeff_wr_en, sfu_coeff_wr_en; wire [1:0] coeff_line_addr;

    // ---- RF read / datapath result ----
    wire [511:0] vrf_rd1,vrf_rd2; wire [15:0] srf_rd1,srf_rd2; wire [511:0] srf_cache_rd;
    wire [511:0] vec_result_vec; wire [15:0] vec_result_scalar, acc_result_scalar;

    //========================================================
    // INSTR_FIFO
    //========================================================
    INSTR_FIFO u_fifo (
        .clk(clk),.rst_n(rst_n),
        .instr_in(instr_in),.enq_valid(enq_valid),.enq_ready(enq_ready),
        .instr_out(instr_out),.deq_valid(deq_valid),.deq_ready(deq_ready)
    );

    //========================================================
    // OP_CONTROL
    //========================================================
    OP_CONTROL u_oc (
        .clk(clk),.rst_n(rst_n),
        .instr(instr_out),.deq_valid(deq_valid),.deq_ready(deq_ready),
        .vrf_rd1_re(vrf_rd1_re),.vrf_rd2_re(vrf_rd2_re),
        .vrf_rd1_addr(vrf_rd1_addr),.vrf_rd2_addr(vrf_rd2_addr),
        .vrf_wr_en(vrf_wr_en),.vrf_wr_addr(vrf_wr_addr),.vrf_wr_sel(vrf_wr_sel),
        .srf_rd1_re(srf_rd1_re),.srf_rd2_re(srf_rd2_re),
        .srf_rd1_addr(srf_rd1_addr),.srf_rd2_addr(srf_rd2_addr),
        .srf_wr_en(srf_wr_en),.srf_wr_addr(srf_wr_addr),.srf_cache_wr_en(srf_cache_wr_en),
        .pwl_coeff_wr_en(pwl_coeff_wr_en),.sfu_coeff_wr_en(sfu_coeff_wr_en),
        .coeff_line_addr(coeff_line_addr),
        .vec_mode(vec_mode),.vec_alu_op(vec_alu_op),.vec_sq(vec_sq),
        .vec_pwl_op(vec_pwl_op),.vec_red_op(vec_red_op),
        .accum_mode(accum_mode),.acc_salu_op(acc_salu_op),
        .acc_op(acc_op),.acc_sfu_op(acc_sfu_op),.acc_flush(acc_flush),
        .wr_sel(wr_sel),
        .lsu_op(lsu_op),.cache_req(cache_req),.cache_we(cache_we),
        .cache_addr(cache_addr),.cache_valid(cache_valid)
    );

    //========================================================
    // VRF (write mux: Load면 cache, 아니면 datapath)
    //========================================================
    wire [511:0] vrf_wr_data = vrf_wr_sel ? cache_rdata : vec_result_vec;
    VRF u_vrf (
        .clk(clk),.rst_n(rst_n),
        .rd1_re(vrf_rd1_re),.rd1_addr(vrf_rd1_addr),.rd1_data(vrf_rd1),
        .rd2_re(vrf_rd2_re),.rd2_addr(vrf_rd2_addr),.rd2_data(vrf_rd2),
        .wr_en(vrf_wr_en),.wr_addr(vrf_wr_addr),.wr_data(vrf_wr_data)
    );

    //========================================================
    // SRF (write mux: 연산결과는 datapath, REDUCE는 vec_scalar)
    //   wr_sel: 0=VEC(reduce result_scalar), 1=ACCUM
    //========================================================
    wire [15:0] srf_wr_data = wr_sel ? acc_result_scalar : vec_result_scalar;
    SRF u_srf (
        .clk(clk),.rst_n(rst_n),
        .rd1_re(srf_rd1_re),.rd1_addr(srf_rd1_addr),.rd1_data(srf_rd1),
        .rd2_re(srf_rd2_re),.rd2_addr(srf_rd2_addr),.rd2_data(srf_rd2),
        .wr_en(srf_wr_en),.wr_addr(srf_wr_addr),.wr_data(srf_wr_data),
        .cache_wr_en(srf_cache_wr_en),.cache_wr_data(cache_rdata),.cache_rd_data(srf_cache_rd)
    );

    //========================================================
    // VEC_DATAPATH (coeff write = 캐시 라인, LDV coeff 공간)
    //========================================================
    VEC_DATAPATH u_vec (
        .clk(clk),.rst_n(rst_n),
        .vrf_rd1(vrf_rd1),.vrf_rd2(vrf_rd2),.srf_scalar(srf_rd1),
        .VEC_MODE(vec_mode),.alu_op(vec_alu_op),.sq_flag(vec_sq),
        .pwl_op(vec_pwl_op),.red_op(vec_red_op),
        .coeff_wr_en(pwl_coeff_wr_en),
        .coeff_wr_line(coeff_line_addr),.coeff_wr_data(cache_rdata),
        .result_vec(vec_result_vec),.result_scalar(vec_result_scalar)
    );

    //========================================================
    // SCALAR_DATAPATH (coeff write = 캐시 라인, LDV coeff 공간)
    //========================================================
    SCALAR_DATAPATH u_scalar (
        .clk(clk),.rst_n(rst_n),
        .srf_rd1(srf_rd1),.srf_rd2(srf_rd2),
        .ACC_MODE(accum_mode),.salu_op(acc_salu_op),
        .acc_op(acc_op),.sfu_op(acc_sfu_op),.acc_flush(acc_flush),
        .coeff_wr_en(sfu_coeff_wr_en),
        .coeff_wr_line(coeff_line_addr),.coeff_wr_data(cache_rdata),
        .result_scalar(acc_result_scalar)
    );

    //========================================================
    // VEC_LSU (Store: cache_wdata)
    //========================================================
    VEC_LSU u_lsu (
        .vrf_rd_data(vrf_rd1),.srf_rd_data(srf_cache_rd),
        .cache_rdata(cache_rdata),.cache_wdata(cache_wdata),
        .vrf_wr_data(),.srf_wr_data(),   // Load write는 TOP에서 mux로 처리
        .lsu_op(lsu_op)
    );
endmodule
