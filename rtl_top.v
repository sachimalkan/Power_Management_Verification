
module rtl_top(clk1, clk2, sel_clk, rst, ck_mx_sw_ctr, lfsr_sw_ctr, iso1, iso2, save_lfsr, restore_lfsr);
input clk1, clk2;
input sel_clk;
input rst;

//power control input
input ck_mx_sw_ctr;//clock mux switch control
input lfsr_sw_ctr; // lfsr switch control
input iso1, iso2;  //isolation control
input save_lfsr, restore_lfsr; //save & restore control

wire clk;
wire lfsr_out;
wire [4:0] lfsr_stored;

//INSTANTIATIONS
clk_mux     CM   (.clk1(clk1), .clk2(clk2), .sel_clk(sel_clk), .clk(clk));
lfsr        LFSR (.reg_out(lfsr_stored), .out(lfsr_out), .clk(clk), .rst(rst));

endmodule
