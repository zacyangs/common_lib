module skid_buffer_tb;

reg clk = 0;
reg rst = 1;


reg         valid = 0;
reg [7:0]   data = 0;
reg         ready = 0;
wire        ready_o;

wire valid_o;
wire [7:0] data_o;


initial begin
#100 rst = 0;
    while(data != 255) begin
        @(posedge clk);
        //if(valid_o && ready) $display("data rcv : %0d", data_o);
    end

    $finish();
end

always #5 clk = ~clk;

relay_station_1 DUT (
    .clk (clk),
    .rst (rst),

    .ready_s(ready_o),
    .valid_s(valid),
    .data_s (data),

    .ready_m(ready),
    .valid_m(valid_o),
    .data_m (data_o)
);


always@(posedge clk)
begin
    if(rst)
        valid <= 1'b0;
    else 
        //valid <= $random % 2;
        valid <= 1;

    if(valid && ready_o)
        data <= data + 1;

    //ready <= $random % 2;
    ready <= 1;
end


initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, skid_buffer_tb);
end

endmodule
