module async_fifo#(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 16
)(
    input                       wclk,
    input                       rclk,
    input                       rstn,

    input                       wr,
    input   [DATA_WIDTH-1:0]    din,
    output                      full,

    input                       rd,
    output  [DATA_WIDTH-1:0]    dout,
    output                      empty
);

localparam ADDR_WIDTH = clog2(DEPTH);

wire                wrstn;
wire                rrstn;

wire [ADDR_WIDTH:0] wr_ptr;
wire [ADDR_WIDTH:0] rd_ptr;

wire [ADDR_WIDTH:0] wr_ptr_sync;
wire [ADDR_WIDTH:0] rd_ptr_sync;

reg  [ADDR_WIDTH:0] wr_ptr_gray;
reg  [ADDR_WIDTH:0] rd_ptr_gray;

wire [ADDR_WIDTH:0] wr_ptr_gray_sync;
wire [ADDR_WIDTH:0] rd_ptr_gray_sync;

assign wr_ptr = gray2bin(wr_ptr_gray);
assign rd_ptr = gray2bin(rd_ptr_gray);

assign wr_ptr_sync = gray2bin(wr_ptr_gray_sync);
assign rd_ptr_sync = gray2bin(rd_ptr_gray_sync);

always@(posedge wclk or negedge wrstn) begin
    if(!wrstn) begin
        wr_ptr_gray <= {ADDR_WIDTH+1{1'b0}};
    end
    else if(wr && !full) begin
        wr_ptr_gray <= bin2gray(wr_ptr + 1);
    end
end

always@(posedge rclk or negedge rrstn) begin
    if(!rrstn) begin
        rd_ptr_gray <= {ADDR_WIDTH+1{1'b0}};
    end
    else if(rd && !empty) begin
        rd_ptr_gray <= bin2gray(rd_ptr + 1);
    end
end

assign empty = wr_ptr_sync[ADDR_WIDTH] == rd_ptr[ADDR_WIDTH] &&
               wr_ptr_sync[ADDR_WIDTH-1:0] == rd_ptr[ADDR_WIDTH-1:0];

assign full  = rd_ptr_sync[ADDR_WIDTH] != wr_ptr[ADDR_WIDTH] &&
               rd_ptr_sync[ADDR_WIDTH-1:0] == wr_ptr[ADDR_WIDTH-1:0];

async_ram_1r1w #(
    .DATA_WIDTH (DATA_WIDTH),
    .ADDR_WIDTH (ADDR_WIDTH)
) 
async_ram_1r1w_u0(
    .wclk   (wclk),
    .rclk   (rclk),
    .wrstn  (wrstn),
    .rrstn  (rrstn),

    .wr     (wr && !full),
    .waddr  (wr_ptr[ADDR_WIDTH-1:0]),
    .wdata  (din),

    .rd     (rd && !empty),
    .raddr  (rd_ptr[ADDR_WIDTH-1:0]),
    .rdata  (dout)
);

synchronizer_rst synchronizer_rst_u0(.clk(wclk), .rstn_in(rstn), .rstn_out(wrstn));
synchronizer_rst synchronizer_rst_u1(.clk(rclk), .rstn_in(rstn), .rstn_out(rrstn));

synchronizer_data #(
    .DATA_WIDTH(ADDR_WIDTH+1)
)
synchronizer_rd_ptr_gray_u0(
    .clk    (wclk),

    .din    (rd_ptr_gray),
    .dout   (rd_ptr_gray_sync)
);

synchronizer_data #(
    .DATA_WIDTH(ADDR_WIDTH+1)
)
synchronizer_wr_ptr_gray_u0(
    .clk    (rclk),

    .din    (wr_ptr_gray),
    .dout   (wr_ptr_gray_sync)
);


function integer clog2;
    input integer depth;
    depth = depth - 1;
    for(clog2 = 1; depth > 1; depth = depth >> 1)
        clog2 = clog2 + 1;
endfunction

function [ADDR_WIDTH:0] gray2bin;
    input [ADDR_WIDTH:0] gray;
    integer i;
    for(i = 0; i < ADDR_WIDTH+1; i = i + 1)
        gray2bin[i] = ^(gray >> i);
endfunction

function [ADDR_WIDTH:0] bin2gray;
    input [ADDR_WIDTH:0] bin;
    bin2gray = bin ^ (bin >> 1);
endfunction

endmodule
