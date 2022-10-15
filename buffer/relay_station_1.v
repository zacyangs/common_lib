module relay_station_1 #(
    parameter DATA_WIDTH = 8
)(
    input   clk,
    input   rst,

    output  reg                 ready_s,
    input                       valid_s,
    input   [DATA_WIDTH-1:0]    data_s,

    input                       ready_m,
    output  reg                 valid_m,
    output  reg [DATA_WIDTH-1:0]data_m
);
localparam EMPTY = 0;
localparam FULL = 1;

reg state, next_state;
wire write, read;

wire ready_s_clr;
wire ready_s_set;
wire valid_m_clr;
wire valid_m_set;

assign write = ready_s && valid_s;
assign read  = ready_m && valid_m;

// clear when write in empty state
assign ready_s_clr = (state == EMPTY) && write;
//set when read in full state
assign ready_s_set = (state == FULL)  && read;

// clear when read in full state, set when write in empty state
assign valid_m_clr = ready_s_set;
assign valid_m_set = ready_s_clr;

always@(posedge clk)
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
        EMPTY : if(write) next_state = FULL;
        FULL  : if(read)  next_state = EMPTY;
    endcase
end

// there is no need to give data_m a initial value
always@(posedge clk) begin
    data_m <= data_s;
end


// valid_m need to be 0, when reset
always@(posedge clk) begin
    if(rst)
        valid_m <= 1'b0;
    else 
        valid_m <= (valid_m && !valid_m_clr) || valid_m_set;
end

// ready_s need to be 1, when reset
always@(posedge clk)
begin
    if(rst)
        ready_s <= 1'b1;
    else 
        ready_s <= (ready_s && !ready_s_clr) || ready_s_set;
end

endmodule
