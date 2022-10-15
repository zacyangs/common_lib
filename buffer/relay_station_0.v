module relay_station_0 #(
    parameter DATA_WIDTH = 8
)(
    input   clk,
    input   rst,

    output  ready_s,
    input   valid_s,
    input   [DATA_WIDTH-1:0]data_s,

    input   ready_m,
    output  reg                 valid_m,
    output  reg [DATA_WIDTH-1:0]data_m
);

always@(posedge clk)
begin
    if(rst)
        valid_m <= 1'b0;
    else if(valid_s && ready_s) begin
        valid_m <= 1'b1;
        data_m  <= data_s;
    end
    else if(ready_m)
        valid_m <= 1'b0;
end

assign ready_s = !valid_m || ready_m;

endmodule
