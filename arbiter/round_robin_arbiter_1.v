module round_robin_arbiter_1#(
    parameter DW = 3
)(
    input                   clk,
    input                   rst,

    input       [DW-1:0]    req,
    output reg  [DW-1:0]    grant
);

reg [DW-1:0] mask;
wire [2*DW-1:0] mask_req;

assign mask_req = {{DW{1'b1}}, ~mask} & req;

always @(*) begin : proc_mask
    case(1)
        grant[0] : mask = 3'b001;
        grant[1] : mask = 3'b011;
        grant[2] : mask = 3'b000;
        default  : mask = 3'b000;
    endcase
end

always @(posedge clk) begin : proc_grant
    if(rst) begin
        grant <= {DW{1'b0}};
    end else begin
        case(1)
            mask_req[0] : grant <= 3'b001;
            mask_req[1] : grant <= 3'b010;
            mask_req[2] : grant <= 3'b100;
            mask_req[3] : grant <= 3'b001;
            mask_req[4] : grant <= 3'b010;
            mask_req[5] : grant <= 3'b100;
            default : grant <= 3'b000;
        endcase
    end
end

endmodule