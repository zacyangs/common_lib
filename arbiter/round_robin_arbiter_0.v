module round_robin_arbiter_0#(
    parameter DW = 3
)(
    input                   clk,
    input                   rst,

    input       [DW-1:0]    req,
    output reg  [DW-1:0]    grant
);

always @(posedge clk) begin : proc_grant
    if(rst) begin
        grant <= {DW{1'b0}};
    end else begin
        case(grant)
            3'b000, 3'b100 : 
                case(1)
                    req[0] : grant <= 3'b001;
                    req[1] : grant <= 3'b010;
                    req[2] : grant <= 3'b100;
                    default : grant <= 3'b000;
                endcase
            3'b001 : 
                case(1)
                    req[1] : grant <= 3'b010;
                    req[2] : grant <= 3'b100;
                    req[0] : grant <= 3'b001;
                    default : grant <= 3'b000;
                endcase
            3'b010 : 
                case(1)
                    req[2] : grant <= 3'b100;
                    req[0] : grant <= 3'b001;
                    req[1] : grant <= 3'b010;
                    default : grant <= 3'b000;
                endcase
        endcase
    end
end

endmodule