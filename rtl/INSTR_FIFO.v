`timescale 1ns / 1ps
//============================================================
// INSTR_FIFO - 명령 입구 (동기, in-order)
//   enq: 외부 → FIFO (instr_in, enq_valid/enq_ready)
//   deq: FIFO → NL_CONTROL (instr_out, deq_valid/deq_ready)
//   동기 read: deq_ready 든 다음 엣지에 head 갱신
//   depth 4 (얕게), 공용 1개
//============================================================
module INSTR_FIFO #(
    parameter DEPTH = 4,
    parameter WIDTH = 20
)(
    input              clk, rst_n,
    // enqueue (외부 명령 입력)
    input  [WIDTH-1:0] instr_in,
    input              enq_valid,
    output             enq_ready,
    // dequeue (NL_CONTROL로)
    output [WIDTH-1:0] instr_out,
    output             deq_valid,
    input              deq_ready
);
    localparam AW = $clog2(DEPTH);
    reg [WIDTH-1:0] mem [0:DEPTH-1];
    reg [AW:0] wr_ptr, rd_ptr;   // 1비트 여유 (full/empty 구분)

    wire empty = (wr_ptr == rd_ptr);
    wire full  = (wr_ptr[AW-1:0] == rd_ptr[AW-1:0]) && (wr_ptr[AW] != rd_ptr[AW]);

    assign enq_ready = ~full;
    assign deq_valid = ~empty;

    // enqueue
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) wr_ptr <= 0;
        else if (enq_valid && enq_ready) begin
            mem[wr_ptr[AW-1:0]] <= instr_in;
            wr_ptr <= wr_ptr + 1;
        end
    end
    // dequeue
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) rd_ptr <= 0;
        else if (deq_ready && deq_valid)
            rd_ptr <= rd_ptr + 1;
    end

    // head 출력 (조합 head, 단 deq_ready로 소비 후 다음 엣지에 rd_ptr 갱신 → 동기 효과)
    assign instr_out = mem[rd_ptr[AW-1:0]];
endmodule