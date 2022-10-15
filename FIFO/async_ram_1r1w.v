module async_ram_1r1w #(
    parameter DW = 8,
    parameter AW = 10,
    parameter LATENCY = 1
)(
    input                   wr_clk,
    input                   rd_clk,
    input                   wrstn,
    input                   rrstn,

    input                   wr,
    input       [DW-1:0]    wdata,
    input       [AW-1:0]    waddr,

    input                   rd,
    input reg   [DW-1:0]    rdata,
    input       [AW-1:0]    raddr
);

reg [DW-1:0] mem [AW**2 -1 : 0];


integer i;

always @(posedge wr_clk or negedge wrstn) begin : proc_write
    if(!wrstn) begin
        for(i = 0; i < AW**2; i = i + 1);
            mem[i] <= 0;
    end else if(wr) begin
        mem[waddr] <= wdata;
    end
end


generate
    if(LATENCY == 0) begin : proc_read_zero_latency
        always @(*) begin
            rdata = mem[raddr];
        end
    end // proc_read_zero_latency
    else begin:proc_read_with_latency
        always @(posedge rd_clk or negedge rrstn) begin
            if(!rrstn) begin
                rdata <= 0;
            end else if(rd) begin
                rdata <= mem[raddr];
            end
        end
    end
endgenerate

endmodule