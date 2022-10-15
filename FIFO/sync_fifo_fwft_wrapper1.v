module sync_fifo_fwft_wrapper1#(
    parameter DW    = 8,
    parameter DEPTH = 128 // need to be 2 ** n
)(
    input               clk,
    input               rst,

    input               rd_en,
    output      [DW-1:0]dout,
    output  reg         empty,

    input               wr_en,
    input   [DW-1:0]    din,
    output  reg         full
);

localparam AW = clog2(DEPTH);

reg [DW-1:0]    ping;
reg [DW-1:0]    pong;
wire[DW-1:0]    ping_next;
wire[DW-1:0]    pong_next;
wire            ping_en;
wire            pong_en;
reg             rd_ptr;
reg             wr_ptr;
reg  [1:0]      usedw_fwft;
reg             dout_fifo_valid;

wire            wr_fifo;
wire            rd_fifo;
wire [AW:0]     usedw_fifo;
wire            wr_fwft;
wire [DW-1:0]   dout_fifo;
wire            empty_fifo;

reg             r_rst;
wire            empty_set;
wire            empty_clr;
wire            full_set;
wire            full_clr;

always @(posedge clk) begin : proc_rst
    r_rst <= rst;
    dout_fifo_valid <= rd_fifo;
end

assign rst_clr = r_rst && !rst;

assign wr_fwft   = wr_en && ((usedw_fwft < 2) && !dout_fifo_valid || rd_en && empty_fifo);
assign ping_en   = (wr_ptr == 0 || wr_fwft && dout_fifo_valid) && (wr_fwft || dout_fifo_valid);
assign pong_en   = (wr_ptr == 1 || wr_fwft && dout_fifo_valid) && (wr_fwft || dout_fifo_valid);

always@(posedge clk) begin : proc_ping
    if(ping_en)
        ping <= (wr_ptr == 0) ? (dout_fifo_valid ? dout_fifo : din) : din;
end

always@(posedge clk) begin : proc_pong
    if(pong_en)
        pong <= (wr_ptr == 1) ? (dout_fifo_valid ? dout_fifo : din) : din;
end

always@(posedge clk) begin : proc_usedw_fwft
    if(rst)
        usedw_fwft <= 0;
    else if((wr_fwft || dout_fifo_valid) && !rd_en)
        usedw_fwft <= usedw_fwft + 1;
    else if(rd_en && !(wr_fwft || dout_fifo_valid))
        usedw_fwft <= usedw_fwft - 1;
end

always @(posedge clk) begin : proc_rd_ptr
    if(rst)
        rd_ptr <= 0;
    else if(rd_en)
        rd_ptr <= ~rd_ptr;
end

always @(posedge clk) begin : proc_wr_ptr
    if(rst)
        wr_ptr <= 0;
    else if(wr_fwft ^ dout_fifo_valid)
        wr_ptr <= ~wr_ptr;
end

sync_fifo#(
    .DW     (DW),
    .DEPTH  (DEPTH)
) sync_fifo_u0 (
  .rst      (rst),
  .clk      (clk),
  .din      (din),
  .wr_en    (wr_fifo),
  .rd_en    (rd_fifo),
  .dout     (dout_fifo),
  .full     (),
  .empty    (empty_fifo),
  .usedw    (usedw_fifo) 
);

assign dout = rd_ptr ? pong : ping;
assign rd_fifo = !empty_fifo && rd_en;
assign wr_fifo = usedw_fwft == 2 && wr_en && !rd_en || !empty_fifo;

// set has higher priority over clear
assign empty_set = rd_en && !wr_en && (usedw_fwft == 1);
assign empty_clr = wr_en && !rd_en;

always @(posedge clk) begin : proc_empty
    if(rst)
        empty <= 1'b1;
    else
        empty <= empty && (!empty_clr) || empty_set;
end

// set has higher priority over clear
assign full_set = wr_en && !rd_en && (usedw_fifo == DEPTH - 1);
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

endmodule // sync_fifo_fwft_wrapper