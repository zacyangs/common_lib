module sync_fifo_fwft_wrapper#(
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
localparam EMPTY = 2'b00;
localparam EHALF = 2'b01;
localparam FHALF = 2'b10;
localparam FULL  = 2'b11;


reg [DW-1:0]    ping;
reg [DW-1:0]    pong;
wire[DW-1:0]    ping_next;
wire[DW-1:0]    pong_next;
wire            ping_en;
wire            pong_en;
reg             rd_ptr;
reg             wr_ptr;
reg  [1:0]      usedw_fwft;


reg             wr_fifo;
wire            rd_fifo;
wire [AW:0]     usedw_fifo;
reg             wr_buff;
wire [DW-1:0]   pop_data;
wire            empty_fifo;

reg             r_rst;
wire            empty_set;
wire            empty_clr;
wire            full_set;
wire            full_clr;
reg [1:0]       state, nstate;
reg             pop_valid;


always @(posedge clk) begin : proc_rst
    r_rst <= rst;
    pop_valid <= rd_fifo;
end

assign rst_clr = r_rst && !rst;

// main FSM 
always @(posedge clk) begin : proc_state
    if(rst) begin
        state <= 0;
    end else begin
        state <= nstate;
    end
end

always @(*) begin : proc_nstate
    nstate = state;
    case(state)
        EMPTY : if(wr_en) nstate = EHALF;
        EHALF : 
            if(wr_en && !rd_en) nstate = FULL;
            else if(rd_en && !wr_en) nstate = EMPTY;
        FHALF : 
            case({wr_buff, pop_valid, rd_en}) // 3'b110, 3'b111 is illegal
                3'b000, 3'b011, 3'b101 : nstate = FHALF;
                3'b001 : nstate = EMPTY;
                3'b010, 3'b100 : nstate = FULL;
                default:;
            endcase
        FULL  : if(rd_en && !pop_valid && !wr_buff) nstate = FHALF;
    endcase
end

always @(*) begin
    wr_buff = wr_en;
    wr_fifo = 0;
    case(state)
        EMPTY : begin
        end
        EHALF : begin
        end
        FHALF : begin
            wr_buff = wr_en && empty_fifo && (rd_en || !pop_valid);
            wr_fifo = wr_en && (!empty_fifo || (pop_valid && !rd_en));
        end
        FULL  : begin
            wr_buff = wr_en && empty_fifo && !pop_valid && rd_en;
            wr_fifo = wr_en && (!rd_en || pop_valid || !empty_fifo);
        end
    endcase
end

assign ping_en   = wr_buff && pop_valid || (wr_ptr == 0) && (wr_buff || pop_valid);
assign pong_en   = wr_buff && pop_valid || (wr_ptr == 1) && (wr_buff || pop_valid);

always@(posedge clk) begin : proc_ping
    if(ping_en)
        ping <= (wr_ptr == 0) ? (pop_valid ? pop_data : din) : din;
end

always@(posedge clk) begin : proc_pong
    if(pong_en)
        pong <= (wr_ptr == 1) ? (pop_valid ? pop_data : din) : din;
end

always@(posedge clk) begin : proc_usedw_fwft
    if(rst)
        usedw_fwft <= 0;
    else if((wr_buff || pop_valid) && !rd_en || (wr_buff && pop_valid))
        usedw_fwft <= usedw_fwft + 1;
    else if(rd_en && !(wr_buff || pop_valid))
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
    else if(wr_buff ^ pop_valid)
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
  .dout     (pop_data),
  .full     (),
  .empty    (empty_fifo),
  .usedw    (usedw_fifo) 
);

assign dout = rd_ptr ? pong : ping;
assign rd_fifo = !empty_fifo && rd_en;


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