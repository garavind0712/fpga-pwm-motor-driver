`timescale 1ns/1ps
module clock_divider_tb;
    logic clk_in;
    logic resetn;
    logic clk_out;

    localparam DIVISOR = 4;

    clock_divider #(.DIVISOR(DIVISOR)) dut (
        .clk_in(clk_in),
        .resetn(resetn),
        .clk_out(clk_out)
    );

    //HOW TO GENERATE CLOCK
    initial clk_in = 0;
    always begin
        #5 clk_in = ~clk_in;
    end

    initial begin
        $dumpfile("sim/clock_divider_tb.vcd");
        $dumpvars(0, clock_divider_tb);

        clk_in = 1'b0;
        resetn = 1'b0;
        #10 resetn = 1'b1; // Release reset after 10 time units
        #500;
        $display("Simulation finished %t", $time);
        $finish; // Finish simulation after 500 time units
    end  
    
endmodule