module round_robin_arbiter_2#(
    parameter DW = 3
)(
    input                   clk,
    input                   rst,

    input       [DW-1:0]    req,
    output      [DW-1:0]    grant
);

reg [DW-1:0] mask;
wire [2*DW-1:0] double_req;

assign grant = {req, req} & ~({req, req} - {{DW{1'b0}, mask})


always @(posedge clk) begin : proc_mask
    if(rst) begin
        mask <= {{DW-1{1'b0}, 1'b1};
    end else if(&grant) begin
        mask <= grant << 1;
    end
end


endmodule