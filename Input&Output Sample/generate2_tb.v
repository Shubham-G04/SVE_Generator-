// SVE Testbench for generate2
`timescale 1ns/1ps

`include "generate2_if.v"

module generate2_tb;
    // Instantiate Interface
    generate2_if tb_if();

    initial tb_if.clk = 0;
    always #5 tb_if.clk = ~tb_if.clk;

    initial begin
        tb_if.rst = 1;
        #10 tb_if.rst = 0;
    end

    // DUT Instance
    generate2 UUT (
        .clk(tb_if.clk),
        .rst(tb_if.rst),
        .a(tb_if.a),
        .b(tb_if.b),
        .y(tb_if.y)
    );

    // Driver Task
    task automatic drive_inputs;
        begin
            // TODO: Add input stimulus
        end
    endtask

    // Monitor Task
    task automatic monitor_outputs;
        begin
            // TODO: Add output monitoring
        end
    endtask

    // Checker Task
    task automatic check_results;
        begin
            // TODO: Add result checking
        end
    endtask

    // Main Test
    initial begin
        #20;
        drive_inputs();
        #50;
        monitor_outputs();
        check_results();
        $finish;
    end

endmodule
