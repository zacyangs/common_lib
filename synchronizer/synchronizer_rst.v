module synchronizer_rst(
    input clk,
    input rstn_in,
    input rstn_out
);

reg [1:0] rst_pipe;

always @(posedge clk or negedge rstn_in) begin : proc_pipe
    if(~rstn_in) begin
        rst_pipe <= 0;
    end else begin
        rst_pipe <= {rst_pipe[0], 1'b1};
    end
end

assign rstn_out = rst_pipe[1];

endmodule // synchronizer_rst