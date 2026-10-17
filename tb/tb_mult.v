`timescale 1ns/1ps

module tb_mult;

    reg clk;
    reg rst_n;
    reg [3:0] a;
    reg [3:0] b;

    wire [7:0] p;

    reg [7:0] expected;

    integer i;
    integer j;
    integer checked;
    integer errors;

    // Device under test
    mult_array dut (
        .clk   (clk),
        .rst_n (rst_n),
        .a     (a),
        .b     (b),
        .p     (p)
    );

    // 10 ns clock period
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin

        // Initialise signals and counters
        rst_n   = 1'b0;
        a       = 4'b0000;
        b       = 4'b0000;
        expected = 8'b00000000;
        checked = 0;
        errors  = 0;

        // Create waveform file
        $dumpfile("mult.vcd");
        $dumpvars(0, tb_mult);

        // Keep reset active for the first two rising clock edges
        repeat (2) @(posedge clk);

        // Release reset on a falling edge
        @(negedge clk);
        rst_n = 1'b1;

        // Test every combination of a and b
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin

                // Apply the input values on a falling edge
                @(negedge clk);
                a = i;
                b = j;
                expected = i * j;

                // Wait for the two-cycle input-to-output latency
                repeat (2) @(posedge clk);
                #1;

                checked = checked + 1;

                // Compare actual and expected products
                if (p !== expected) begin
                    $display(
                        "MISMATCH: a=%0d b=%0d expected=%0d got=%0d",
                        a, b, expected, p
                    );

                    errors = errors + 1;
                end

            end
        end

        // Print exactly one final summary line
        if (errors == 0) begin
            $display(
                "PASS: %0d vectors checked, %0d errors",
                checked, errors
            );
        end else begin
            $display(
                "FAIL: %0d vectors checked, %0d errors",
                checked, errors
            );
        end

        $finish;

    end

endmodule
