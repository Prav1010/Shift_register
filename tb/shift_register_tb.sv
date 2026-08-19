`timescale 1ns/1ps

module shift_register_tb;

    parameter WIDTH = 8;
    parameter DEPTH = 4;
    parameter DIR   = 1; // 1 = left, 0 = right

    reg                  clk;
    reg                  rst_n;
    reg                  en;
    reg                  load;
    reg                  serial_in;
    reg  [WIDTH-1:0]     parallel_in;
    wire [WIDTH-1:0]     parallel_out;
    wire                 serial_out;

    integer errors = 0;
    integer tests  = 0;

    shift_register #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH),
        .DIR(DIR)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .load(load),
        .serial_in(serial_in),
        .parallel_in(parallel_in),
        .parallel_out(parallel_out),
        .serial_out(serial_out)
    );

    // Clock generation: 10ns period
    always #5 clk = ~clk;

    // Dump waveforms
    initial begin
        $dumpfile("waveforms.vcd");
        $dumpvars(0, shift_register_tb);
    end

    // Test procedure
    initial begin
        clk = 0;
        rst_n = 0;
        en = 0;
        load = 0;
        serial_in = 0;
        parallel_in = 0;

        // Test 1: Reset check
        tests = tests + 1;
        @(negedge clk);
        rst_n = 0;
        @(negedge clk);
        if (parallel_out !== 0) begin
            $display("FAIL: Test 1 Reset - parallel_out = %0h, expected 0", parallel_out);
            errors = errors + 1;
        end else begin
            $display("PASS: Test 1 Reset");
        end

        // Release reset
        rst_n = 1;
        @(negedge clk);

        // Test 2: Parallel load
        tests = tests + 1;
        en = 1;
        load = 1;
        parallel_in = 8'hA5;
        repeat (DEPTH) @(negedge clk);
        load = 0;
        if (parallel_out !== 8'hA5) begin
            $display("FAIL: Test 2 Parallel Load - parallel_out = %0h, expected A5", parallel_out);
            errors = errors + 1;
        end else begin
            $display("PASS: Test 2 Parallel Load");
        end

        // Test 3: Serial shift (left, since DIR=1)
        tests = tests + 1;
        rst_n = 0;
        @(negedge clk);
        rst_n = 1;
        @(negedge clk);
        serial_in = 1;
        @(negedge clk);
        serial_in = 0;
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        $display("INFO: Test 3 Serial Shift - parallel_out = %0h", parallel_out);

        // Test 4: Disable (en = 0) should hold value
        tests = tests + 1;
        en = 0;
        begin
            reg [WIDTH-1:0] held_value;
            held_value = parallel_out;
            @(negedge clk);
            if (parallel_out !== held_value) begin
                $display("FAIL: Test 4 Hold - value changed while en=0");
                errors = errors + 1;
            end else begin
                $display("PASS: Test 4 Hold");
            end
        end

        // Test 5: Re-enable and load again
        tests = tests + 1;
        en = 1;
        load = 1;
        parallel_in = 8'h3C;
        repeat (DEPTH) @(negedge clk);
        load = 0;
        if (parallel_out !== 8'h3C) begin
            $display("FAIL: Test 5 Reload - parallel_out = %0h, expected 3C", parallel_out);
            errors = errors + 1;
        end else begin
            $display("PASS: Test 5 Reload");
        end

        // Summary
        $display("----------------------------------------");
        $display("TESTS RUN: %0d, ERRORS: %0d", tests, errors);
        if (errors == 0)
            $display("RESULT: ALL TESTS PASSED");
        else
            $display("RESULT: SOME TESTS FAILED");
        $display("----------------------------------------");

        #20;
        $finish;
    end

endmodule