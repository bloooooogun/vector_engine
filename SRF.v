`timescale 1ns / 1ps
//============================================================
// SRF - scalar register file (32엔트리 16b, register array)
//   캐시 512b(전체) + 연산 16b(rd1/rd2 2포트, 포트별 re)
//   안 쓰는 포트 re=0 (VRF와 일관, SRAM화 대비)
//============================================================
module SRF (
    input         clk, rst_n,
    // 연산용 16b read 2포트 (포트별 enable)
    input         rd1_re,
    input  [4:0]  rd1_addr,
    output [15:0] rd1_data,
    input         rd2_re,
    input  [4:0]  rd2_addr,
    output [15:0] rd2_data,
    // 연산용 16b write 1포트
    input         wr_en,
    input  [4:0]  wr_addr,
    input  [15:0] wr_data,
    // 캐시용 512b (전체 32엔트리, 주소 불필요)
    input         cache_wr_en,
    input  [511:0] cache_wr_data,
    output [511:0] cache_rd_data
);
    reg [15:0] mem [0:31];
    integer i;

    // ---- write (캐시 512b 우선, 아니면 연산 16b) ----
    always @(posedge clk) begin
        if (cache_wr_en) begin
            for (i=0; i<32; i=i+1)
                mem[i] <= cache_wr_data[i*16 +: 16];
        end else if (wr_en) begin
            mem[wr_addr] <= wr_data;
        end
    end

    // ---- 16b read (포트별 re, 동기) ----
    reg [15:0] rd1_data_r, rd2_data_r;
    always @(posedge clk) begin
        if (rd1_re) rd1_data_r <= mem[rd1_addr];
        if (rd2_re) rd2_data_r <= mem[rd2_addr];
    end
    assign rd1_data = rd1_data_r;
    assign rd2_data = rd2_data_r;

    // ---- 512b read (조합, 전체 concat) ----
    genvar g;
    generate
        for (g=0; g<32; g=g+1) begin: cache_rd
            assign cache_rd_data[g*16 +: 16] = mem[g];
        end
    endgenerate
endmodule