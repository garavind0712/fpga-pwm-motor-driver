module pwm_gen#(
    parameter PWM_WIDTH)
    (
        input logic clk,
        input logic resetn,
        input logic [PWM_WIDTH-1:0] duty_cycle,
        output logic pwm_out
    );

    logic [PWM_WIDTH-1:0] counter;

    always_ff @(posedge clk or negedge resetn) begin
        if(!resetn || (counter == {PWM_WIDTH{1'b1}})) begin
            counter <= 0;
        end
        else begin
            counter <= counter + 1;
        end
    end

    assign pwm_out = (counter < duty_cycle) ? 1'b1 : 1'b0;

endmodule