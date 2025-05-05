module clk_mux (
    input clk1, clk2, sel_clk, 
    output clk
);

// Complete clock mux function 
assign clk = sel_clk ? clk2 : clk1;
    
endmodule