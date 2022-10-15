module priority_arbiter_0(
    input   clk,
    input   rst,

    input       [2:0]   req,
    output reg  [2:0]   grant
);

always @(posedge clk) begin : proc_grant
    if(rst) begin
        grant <= 0;
    end else begin
        casex(1)
            req[0] : grant <= 3'b001;
            req[1] : grant <= 3'b010;
            req[2] : grant <= 3'b100;
            default : grant <= 3'b000;
        endcase
    end
end

endmodule