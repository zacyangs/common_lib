module gray2bin#(
    parameter DATA_WIDTH = 4
)(
    input       [DATA_WIDTH-1:0] gray,
    output reg  [DATA_WIDTH-1:0] bin
);

integer i;
always @(*) begin : proc_gray2bin
    for(i = 0; i < DATA_WIDTH; i = i + 1)
        bin[i] = ^(gray>>i);
end


endmodule

