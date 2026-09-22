`timescale 1ns / 1ps
//============================================================
// VRF - vector register file (32엔트리 512b, 인터리브 2뱅크)
//   addr[0]=뱅크선택(짝→0/홀→1), addr[4:1]=뱅크내주소(16엔트리)
//   rd1/rd2 동시 read (다른 뱅크면 OK), 동기 1 cycle
//   포트별 read enable: 안 쓰는 포트는 re=0 → 뱅크 점유 안 함
//     (SRAM 싱글포트 뱅크에서 충돌 회피. 단항은 rd2_re=0)
//   충돌(rd1,rd2 같은 뱅크 동시)은 상위가 주소 배치로 회피
//============================================================
module VRF (
    input         clk, rst_n,
    // read 포트 2개 (포트별 enable)
    input         rd1_re,
    input  [4:0]  rd1_addr,
    output [511:0] rd1_data,
    input         rd2_re,
    input  [4:0]  rd2_addr,
    output [511:0] rd2_data,
    // write 포트 1개
    input         wr_en,
    input  [4:0]  wr_addr,
    input  [511:0] wr_data
);
    reg [511:0] bank0 [0:15];   // 짝수 주소
    reg [511:0] bank1 [0:15];   // 홀수 주소

    // ---- write ----
    always @(posedge clk) begin
        if (wr_en) begin
            if (wr_addr[0]) bank1[wr_addr[4:1]] <= wr_data;
            else            bank0[wr_addr[4:1]] <= wr_data;
        end
    end

    // ---- 동기 read (포트별 re) ----
    reg [511:0] rd1_data_r, rd2_data_r;
    always @(posedge clk) begin
        if (rd1_re)
            rd1_data_r <= rd1_addr[0] ? bank1[rd1_addr[4:1]] : bank0[rd1_addr[4:1]];
        if (rd2_re)
            rd2_data_r <= rd2_addr[0] ? bank1[rd2_addr[4:1]] : bank0[rd2_addr[4:1]];
    end
    assign rd1_data = rd1_data_r;
    assign rd2_data = rd2_data_r;
endmodule