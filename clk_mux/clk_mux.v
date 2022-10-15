module clk_mux(
    input   sel,

    input   clk_0,
    input   clk_1,

    output  clk_o
);

reg sel_sync_0;
reg sel_sync_1;

reg sel_lock_0;
reg sel_lock_1;

always@(posedge clk_0)
    sel_sync_0 <= sel && (~sel_lock_1);

always@(posedge clk_1)
    sel_sync_1 <= sel && (~sel_lock_0);

always@(negedge clk_0)
    sel_lock_0 <= sel_sync_0;

always@(negedge clk_1)
    sel_lock_1 <= sel_sync_1;

assign clk_o = sel_lock_0 & clk_0 || sel_lock_1 & clk_1;

endmodule