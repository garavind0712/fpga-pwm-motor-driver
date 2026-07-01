/*Testbench Goal:
This testbench is used to verify if the PWM signal 
is being generated as expected and varies 
according to the duty cycle input.*/

`timescale 1ns/1ps
module pwm_tb();
    logic clk;
    logic resetn;
    logic [7:0] duty_cycle;
    logic pwm_out;

    localparam PWM_WIDTH = 8;
    pwm_gen #(.PWM_WIDTH(PWM_WIDTH)) dut (
        .clk(clk),
        .resetn(resetn),
        .duty_cycle(duty_cycle),
        .pwm_out(pwm_out)
    );

    // Clock generation
    initial clk = 0;
    always begin
        #5 clk = ~clk; // 100 MHz clock
    end

    logic [PWM_WIDTH-1:0] test_counter;
    logic [PWM_WIDTH-1:0] clock_counter;
    int errors = 0;

    always_ff @(posedge clk)begin
        if(!resetn)begin
            test_counter <= 0;
            clock_counter <= 0;
        end
        else if(clock_counter == (2**PWM_WIDTH - 1))begin
            logic [PWM_WIDTH-1:0] expected_duty_cycle;
            expected_duty_cycle = pwm_out ? test_counter + 1 : test_counter;
            if(expected_duty_cycle == duty_cycle)begin
                $display("Test passed at time %t: duty_cycle = %0d, expected_duty_cycle = %0d -> PASS", $time, duty_cycle, expected_duty_cycle);
            end
            else begin
                $display("Test failed at time %t: duty_cycle = %0d, expected_duty_cycle = %0d -> FAIL", $time, duty_cycle, expected_duty_cycle);
                errors++;
            end
            test_counter <= 0; // Reset test counter
            clock_counter <= 0; // Reset clock counter 
        end
        else begin
            test_counter<= pwm_out ? test_counter + 1 : test_counter;
            clock_counter <= clock_counter + 1;
        end
    end

    initial begin
        $dumpfile("sim/pwm_tb.vcd");
        $dumpvars(0, pwm_tb);

        resetn = 1'b0;
        duty_cycle = 8'd0;
        #10 resetn = 1'b1; // Release reset after 10 time units

        // Test different duty cycles
        for (int dc = 0; dc < 256; dc = dc + 32) begin
            duty_cycle = dc[7:0];
            #(2**PWM_WIDTH * 10); // Wait for a few PWM cycles to observe the output
        end

        if(errors == 0)begin
            $display("All tests passed!");
        end
        else begin
            $display("%0d tests failed.", errors);
        end

        $display("Simulation finished %t", $time);
        $finish; // Finish simulation after all tests
    end
endmodule