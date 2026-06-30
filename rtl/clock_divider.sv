module clock_divider #(
    parameter DIVISOR
) (
    input logic clk_in,
    input logic resetn,
    output logic clk_out
);
    int counter = 0;
    always_ff @(posedge clk_in) begin
        if (!resetn) begin
            clk_out <= 1'b0;
            counter <= 0;
        end else begin
            counter <= counter + 1;
            if (counter == DIVISOR - 1) begin
                clk_out <= ~clk_out;
                counter <= 0;
            end
        end
    end 
endmodule