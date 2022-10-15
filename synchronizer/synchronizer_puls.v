module synchronizer_puls(
    input   sclk,
    input   srstn,
    input   puls_in,

    input   dclk,
    input   drstn,
    output  puls_out
);

reg     slevel;
reg     dlevel;
reg     dpuls;
reg     r_dlevel;

always @(posedge sclk or negedge srstn) begin : proc_slevel
    if(~srstn) begin
        slevel <= 0;
    end else begin
        slevel <= puls_in ^ slevel;
    end
end

synchronizer_data synchronizer_data_u0(
    .clk    (dclk),
    .din    (slevel),
    .dout   (dlevel)
);

always @(posedge dclk or negedge drstn) begin : proc_slevel
    if(~srstn) begin
        r_dlevel <= 0;
    end else begin
        r_dlevel <= dlevel;
    end
end

assign puls_out = dlevel ^ r_dlevel;

//always@(posedge sclk)
//assert(puls_in == 1 => puls_in == 0)


endmodule // synchronizer_puls