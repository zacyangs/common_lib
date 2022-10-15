module synchronizer_data(
    input   clk,
    input   din,
    output  dout
);

(* ASYNC_REG = "TRUE" *) reg [1:0] pipeline;

always_ff @(posedge clk) begin : proc_pipeline
    pipeline <= {pipeline[0], din};
end

assign dout = pipeline[1];

endmodule