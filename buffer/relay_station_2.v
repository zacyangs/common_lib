module relay_station_2 #(
    parameter DATA_WIDTH = 8
)(
    input   clk,
    input   rst,

    output  reg                 ready_s,
    input                       valid_s,
    input   [DATA_WIDTH-1:0]    data_s,

    input                       ready_m,
    output                      valid_m,
    output  [DATA_WIDTH-1:0]    data_m
);
localparam EMPTY = 0;
localparam HALF  = 1;
localparam FULL  = 2;

reg [1:0] state, next_state;

reg valid_aux, valid_main;
reg [DATA_WIDTH-1:0] data_aux, data_main;

wire write, read;
wire load, unload;
wire fill, flush;
wire flow;

assign write = ready_s && valid_s;
assign read  = ready_m && valid_m;

assign load     = state == EMPTY &&  write && !read;
assign unload   = state == HALF  && !write &&  read;
assign flow     = state == HALF  &&  write &&  read;
assign fill     = state == HALF  &&  write && !read;
assign flush    = state == FULL  && !write &&  read;

always @(posedge clk)
begin
    if(rst)
        state <= EMPTY;
    else 
        state <= next_state;
end

always@(*)
begin
    next_state = state;
    case(state)
        EMPTY : if(load) next_state = HALF;
        HALF  : 
            if(unload) next_state = EMPTY;
            else if(fill) next_state = FULL;
        FULL : if(flush) next_state = HALF;
    endcase
end

always@(posedge clk)
begin
    if(rst)
        valid_main = 0;
    else if(load || flow)
        valid_main <= 1'b1;
    else if(unload)
        valid_main <= 1'b0;
end

always@(posedge clk)
begin
    if(load||flow) data_main <= data_s;
    else if(flush) data_main <= data_aux;
end

always@(posedge clk)
begin
    if(rst)
        valid_aux = 0;
    else if(fill)
        valid_aux <= 1'b1;
    else if(flush)
        valid_aux <= 1'b0;
end

always@(posedge clk)
begin
    if(fill) data_aux <= data_s;
end

always@(posedge clk)
begin
    if(rst)
        ready_s <= 1'b1;
    else
        ready_s <= (ready_s && !fill) || flush;
end
assign valid_m = valid_main;
assign data_m = data_main;


endmodule
