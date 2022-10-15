module bin2gray#(
    parameter DATA_WIDTH = 4
)(
    input       [DATA_WIDTH-1:0] bin,
    output      [DATA_WIDTH-1:0] gray
);

assign gray = bin ^ (bin >> 1);

endmodule