#!/usr/bin/perl
use strict;
use warnings;

# Read command-line arguments
my ($module_name, $num_inputs, $num_outputs, $input_names, $output_names, $clk, $rst, $width, $output_dir) = @ARGV;
die "Usage: generate_sve.pl <module_name> <num_inputs> <num_outputs> <input_names> <output_names> <clk> <rst> <width> <output_dir>\n" unless defined $module_name;


my @input_signals  = $input_names  ? split(/,/, $input_names)  : map { "in$_" } (0 .. $num_inputs - 1);
my @output_signals = $output_names ? split(/,/, $output_names) : map { "out$_" } (0 .. $num_outputs - 1);


my $module_file     = "$output_dir/$module_name.v";
my $testbench_file  = "$output_dir/${module_name}_tb.v";
my $interface_file  = "$output_dir/${module_name}_if.v";

# -----------------------------
# Generate Interface Definition
# -----------------------------
open(my $intf, '>', $interface_file) or die "Cannot open interface file: $!";
print $intf "interface ${module_name}_if;\n";

# Clock/reset
print $intf "    logic clk;\n" if $clk;
print $intf "    logic rst;\n" if $rst;

# Input signals
for my $sig (@input_signals) {
    print $intf "    logic [$width-1:0] $sig;\n";
}

# Output signals
for my $sig (@output_signals) {
    print $intf "    logic [$width-1:0] $sig;\n";
}

print $intf "endinterface\n";
close($intf);
print "Generated interface: $interface_file\n";

# -------------------------
# Generate Verilog Module
# -------------------------
open(my $fh, '>', $module_file) or die "Cannot open module file: $!";
print $fh "module $module_name (\n";

print $fh "    input wire clk,\n" if $clk;
print $fh "    input wire rst,\n" if $rst;

for my $i (0 .. $#input_signals) {
    print $fh "    input wire [$width-1:0] $input_signals[$i],\n";
}

for my $i (0 .. $#output_signals) {
    print $fh "    output wire [$width-1:0] $output_signals[$i]";
    print $fh "," if $i < $#output_signals;
    print $fh "\n";
}

print $fh ");\n\n// DUT logic here\n\nendmodule\n";
close($fh);
print "Generated module: $module_file\n";

# -----------------------------
# Generate SVE-Style Testbench
# -----------------------------
open(my $tb, '>', $testbench_file) or die "Cannot open testbench file: $!";

print $tb <<HEADER;
// SVE Testbench for $module_name
`timescale 1ns/1ps

`include "${module_name}_if.v"

module ${module_name}_tb;
    // Instantiate Interface
    ${module_name}_if tb_if();

HEADER

# Clock generation
if ($clk) {
    print $tb "    initial tb_if.clk = 0;\n";
    print $tb "    always #5 tb_if.clk = ~tb_if.clk;\n\n";
}

# Reset generation
if ($rst) {
    print $tb "    initial begin\n";
    print $tb "        tb_if.rst = 1;\n";
    print $tb "        #10 tb_if.rst = 0;\n";
    print $tb "    end\n\n";
}

# DUT
print $tb "    // DUT Instance\n";
print $tb "    $module_name UUT (\n";
print $tb "        .clk(tb_if.clk),\n" if $clk;
print $tb "        .rst(tb_if.rst),\n" if $rst;

foreach my $sig (@input_signals) {
    print $tb "        .$sig(tb_if.$sig),\n";
}
foreach my $i (0 .. $#output_signals) {
    my $sig = $output_signals[$i];
    my $comma = ($i == $#output_signals) ? "" : ",";
    print $tb "        .$sig(tb_if.$sig)$comma\n";
}
print $tb "    );\n\n";

# Test sequence
print $tb <<BODY;
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
        \$finish;
    end

endmodule
BODY

close($tb);
print "Generated SVE-style testbench: $testbench_file\n";
