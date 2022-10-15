module skid_buffer#(
    parameter DATA_WIDTH = 8
)(
    input   clk,
    input   rst,

    output  reg ready_s,
    input   valid_s,
    input   [DATA_WIDTH-1:0]data_s,

    input   ready_m,
    output  valid_m,
    output  [DATA_WIDTH-1:0]data_m
);

reg [1:0] valid_r;
reg [DATA_WIDTH-1:0] data_r [1:0];
reg [1:0] wr_ptr;
reg [1:0] rd_ptr;
wire read;
wire write;

assign read = ready_m && valid_m;
assign write = ready_s && valid_s;

always@(posedge clk)
begin
    if(rst)
        wr_ptr <= 2'b00;
    else if(write)
        wr_ptr <= wr_ptr + 1;

    if(rst)
        ready_s <= 1'b0;
    else
        ready_s <= rd_ptr[1] == wr_ptr[1] || rd_ptr[0] != wr_ptr[0] && !(write && !read);
end

always@(posedge clk)
begin
    if(rst)
        rd_ptr <= 2'b00;
    else if(read)
        rd_ptr <= rd_ptr + 1;
end


always@(clk)
begin
    if(write)
        data_r[wr_ptr[0]] <= data_s;
end

//assign ready_s = rd_ptr[1] == wr_ptr[1] || rd_ptr[0] != wr_ptr[0];
assign valid_m = rd_ptr != wr_ptr;
assign data_m  = data_r[rd_ptr[0]];

endmodule
