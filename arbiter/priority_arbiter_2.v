module priority_arbiter_2#(
    parameter DW = 4
)(
    input   clk,
    input   rst,

    input       [DW-1:0]   req,
    output reg  [DW-1:0]   grant
);

wire [DW-1:0] grant_t;

assign grant_t = {grant_t[DW-2:1], 1'b1} & req;

always @(posedge clk) begin : proc_grant
    if(rst) begin
        grant <= {DW{1'b0}};
    end else begin
        grant <= grant_t；
    end
end

endmodule