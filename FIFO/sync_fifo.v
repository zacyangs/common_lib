module sync_fifo#(
    parameter DW = 8,
    parameter DEPTH = 128 // need to be 2 ** n
)(
    input               clk,
    input               rst,

    input               rd_en,
    output  reg [DW-1:0]dout,
    output  reg         empty,

    input               wr_en,
    input   [DW-1:0]    din,
    output  reg         full,

    output  reg  [AW:0] usedw
);

localparam AW = clog2(DEPTH);

reg  [DW-1:0] mem [DEPTH-1:0];
wire [AW-1:0] rptr_next;
wire [AW-1:0] wptr_next;
reg  [AW-1:0] rptr;
reg  [AW-1:0] wptr;
//reg  [AW:0] usedw;
wire empty_set;
wire empty_clr;
wire full_set;
wire full_clr;
wire rst_clr;
reg  r_rst;

wire read_only;
wire write_only;
wire read_write;

assign read_write = rd_en && wr_en;
assign read_only  = rd_en && !wr_en;
assign write_only = !rd_en && wr_en;

assign wptr_next = wr_en? wptr + 1 : wptr;
assign rptr_next = rd_en? rptr + 1 : rptr;

always @(posedge clk) begin : proc_rst
    r_rst <= rst;
end

assign rst_clr = r_rst && !rst;

always @(posedge clk) begin : proc_wptr
    if(rst)
        wptr <= 0;
    else
        wptr <= wptr_next;
end

always @(posedge clk) begin : proc_rptr
    if(rst)
        rptr <= 0;
    else
        rptr <= rptr_next;
end

// used words in the fifo
always @(posedge clk) begin : proc_usedw
    if(rst) begin
        usedw <= 0;
    end else if(rd_en && !wr_en) begin
        usedw <= usedw - 1;
    end else if(!rd_en && wr_en) begin
        usedw <= usedw + 1;
    end
end

always @(posedge clk) begin : proc_write
    if(wr_en)
        mem[wptr] <= din;
end

always @(posedge clk) begin : proc_read
    if(rd_en)
        dout <= mem[rptr];
end

// set has higher priority over clear
assign empty_set = rd_en && !wr_en && (usedw == 1);
assign empty_clr = wr_en && !rd_en;

always @(posedge clk) begin : proc_empty
    if(rst)
        empty <= 1'b1;
    else
        empty <= empty && (!empty_clr) || empty_set;
end

// set has higher priority over clear
assign full_set = wr_en && !rd_en && (usedw == DEPTH - 1);
assign full_clr = rd_en && !wr_en || rst_clr;

always @(posedge clk) begin : proc_full
    if(rst)
        full <= 1'b1;
    else
        full <= full && (!full_clr) || full_set;
end

function integer clog2;
    input integer depth;
begin
    depth = depth - 1;
    for(clog2 = 1; depth > 1; depth = depth >> 1)
        clog2 = clog2 + 1;
end
endfunction

endmodule // sync_fifo