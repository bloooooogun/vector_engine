`timescale 1ns / 1ps
//============================================================
// VEC_LSU - 캐시 ↔ VRF/SRF 데이터 이동 (1차, single in-flight)
//
//   opcode 0~3 (LSU):
//     Load_vector(0):  캐시 → VRF (512b)
//     Store_vector(1): VRF → 캐시 (512b)
//     Load_scalar(2):  캐시 → SRF (512b 전체)
//     Store_scalar(3): SRF → 캐시 (512b 전체)
//
//   순수 데이터 경로 (제어는 OP_CONTROL FSM):
//     Load:  cache_rdata → RF wr_data
//     Store: RF rd_data → cache_wdata
//   valid 핸드셰이크는 OP_CONTROL이 (cache_valid 대기)
//============================================================
module VEC_LSU (
    // RF read (Store 시)
    input  [511:0] vrf_rd_data,    // VRF read (Store_vector)
    input  [511:0] srf_rd_data,    // SRF 512b read (Store_scalar)
    // 캐시
    input  [511:0] cache_rdata,    // Load 시 캐시 데이터
    output [511:0] cache_wdata,    // Store 시 캐시로
    // RF write (Load 시)
    output [511:0] vrf_wr_data,    // → VRF (Load_vector)
    output [511:0] srf_wr_data,    // → SRF (Load_scalar)
    // 제어
    input  [1:0]   lsu_op          // 0=Ld_vec/1=St_vec/2=Ld_sc/3=St_sc
);
    // Load: 캐시 → RF (그대로 통과)
    assign vrf_wr_data = cache_rdata;   // Load_vector
    assign srf_wr_data = cache_rdata;   // Load_scalar (512b → SRF 전체)

    // Store: RF → 캐시 (lsu_op로 VRF/SRF 선택)
    assign cache_wdata = (lsu_op == 2'd3) ? srf_rd_data : vrf_rd_data;
    //   St_scalar(3): SRF, St_vector(1): VRF
endmodule