// Kaelyn Cho
// cite: ChatGPT

module lfsr (
    input clk, rst, 
    output out, 
    output [4:0] reg_out

);
   // Complete LFSR function
   wire dff_out;  // Output of the DFF for feedback

    // 5-bit shift register using DFFs
    DFF dff0 (.clk(clk), .rst(rst), .d(dff_out), .q(reg_out[0]));
    DFF dff1 (.clk(clk), .rst(rst), .d(reg_out[0]), .q(reg_out[1]));
    DFF dff2 (.clk(clk), .rst(rst), .d(reg_out[1]), .q(reg_out[2]));
    DFF dff3 (.clk(clk), .rst(rst), .d(reg_out[2]), .q(reg_out[3]));
    DFF dff4 (.clk(clk), .rst(rst), .d(reg_out[3]), .q(reg_out[4]));

    // XOR for feedback - using taps at bit positions 4 and 1
    assign dff_out = reg_out[4] ^ reg_out[1];

    // Output the LFSR's last bit
    assign out = reg_out[4];
    
endmodule

// You also need to create two modules: DFF and DFF_H
module DFF (
    input clk,        // Clock input
    input rst,        // Reset input
    input d,          // Data input
    output reg q      // Output
);
    always @(posedge clk or negedge rst) begin
        if (!rst)
            q <= 1'b0;  // Reset output to 0 when reset is low
        else
            q <= d;     // Store the input value at the rising edge of the clock
    end
endmodule

module DFF_H (
    input clk,        // Clock input
    input rst,        // Reset input
    input d,          // Data input
    output reg q      // Output
);
    always @(posedge clk or negedge rst) begin
        if (!rst)
            q <= 1'b1;  // Reset output to 1 when reset is low
        else
            q <= d;     // Store the input value at the rising edge of the clock
    end
endmodule
