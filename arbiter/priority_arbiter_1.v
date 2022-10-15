module priority_arbiter_1#(
    parameter DW = 4
)(
    input   clk,
    input   rst,

    input       [DW-1:0]   req,
    output reg  [DW-1:0]   grant
);



always @(posedge clk) begin : proc_grant
    if(rst) begin
        grant <= {DW{1'b0}};
    end else begin
        grant <= req & ~(req - 1)；
    end
end

endmodule