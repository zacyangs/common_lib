module skid_buffer#(
    parameter DATA_WIDTH = 8
)(
    input   clk,
    input   rst,

    output  reg ready_s,
    input   valid_s,
    input   [DATA_WIDTH-1:0]data_s,

    input   ready_m,
    output  reg valid_m,
    output  [DATA_WIDTH-1:0]data_m
);

reg [DATA_WIDTH-1:0] data_r [1:0];


always@(posedge clk)
begin
    if(rst)
        ready_s <= 1'b0;
    else 
        ready_s <= !valid_m && !ready_s || valid_m && ready_m;

    if(rst)
        valid_m <= 1'b0;
    else if(valid_s && ready_s) begin
        valid_m <= 1'b1;
        data_r[0] <= data_s;
    end
    else if(ready_m)
        valid_m <= 1'b0;
end

assign data_m  = data_r[0];

endmodule
