#!/usr/bin/tclsh
package require Tk

# Global Variables
set mod_name ""
set num_inputs ""
set num_outputs ""
set input_names ""
set output_names ""
set clk_enabled 0
set rst_enabled 0
set data_width 1
set output_dir "."


wm title . "SVE Module Generator"
label .title -text "System Verification Environment (SVE) Generator" -font {Arial 14 bold}
pack .title -padx 10 -pady 10


label .l1 -text "Module Name:"
entry .e1 -textvariable mod_name
pack .l1 .e1 -side top -anchor w -padx 10 -pady 5


label .l2 -text "Number of Input Signals:"
entry .e2 -textvariable num_inputs
pack .l2 .e2 -side top -anchor w -padx 10 -pady 5


label .l4 -text "Input Signal Names (comma-separated):"
entry .e4 -textvariable input_names
pack .l4 .e4 -side top -anchor w -padx 10 -pady 5


label .l3 -text "Number of Output Signals:"
entry .e3 -textvariable num_outputs
pack .l3 .e3 -side top -anchor w -padx 10 -pady 5


label .l5 -text "Output Signal Names (comma-separated):"
entry .e5 -textvariable output_names
pack .l5 .e5 -side top -anchor w -padx 10 -pady 5


checkbutton .cb_clk -text "Include Clock" -variable clk_enabled
checkbutton .cb_rst -text "Include Reset" -variable rst_enabled
pack .cb_clk .cb_rst -padx 10 -pady 5 


label .l6 -text "Signal Width (bits):"
ttk::combobox .cb_width -values {1 8 16 32} -textvariable data_width
pack .l6 .cb_width -side top -anchor w -padx 10 -pady 5
set data_width 1  ;# Default value

# Select Output Directory
button .b2 -text "Select Output Folder" -command {
    global output_dir
    set dir [tk_chooseDirectory]
    if {$dir ne ""} { set output_dir $dir }
}
pack .b2 -pady 10

# Status Log Box
label .l7 -text "Status Log:"
text .status_text -width 60 -height 10
pack .l7 .status_text -padx 10 -pady 5

# Log function
proc log_message {msg} {
    .status_text insert end "$msg\n"
    .status_text see end
}

# Button Generate 
proc generate_module {} {
    global mod_name num_inputs num_outputs input_names output_names clk_enabled rst_enabled data_width output_dir

    set mod $mod_name
    set inputs $num_inputs
    set outputs $num_outputs
    set in_names $input_names
    set out_names $output_names
    set clk $clk_enabled
    set rst $rst_enabled
    set width $data_width

    if {$mod eq "" || $inputs eq "" || $outputs eq ""} {
        tk_messageBox -message "Please fill all fields!" -icon warning
        return
    }

    set cmd "perl generate_sve.pl \"$mod\" \"$inputs\" \"$outputs\" \"$in_names\" \"$out_names\" \"$clk\" \"$rst\" \"$width\" \"$output_dir\""
    log_message "Executing: $cmd"

    if {[catch {exec {*}$cmd} result]} {
        log_message "Error: $result"
        tk_messageBox -message "Error: $result" -icon error
    } else {
        log_message "Module $mod generated successfully!"
        tk_messageBox -message "Module $mod generated successfully!" -icon info
    }
}

# Create Module Button
button .b1 -text "Create Module" -command generate_module
pack .b1 -pady 10

# Open Generated File Button
button .b3 -text "Open Module File" -command {
    global mod_name output_dir
    if {$mod_name ne ""} {
        exec notepad++ "$output_dir/$mod_name.v" &
    }
}
pack .b3 -pady 2

# Run Simulation Button
#button .b4 -text "Run Simulation" -command {
#    global mod_name output_dir
#    set compile_out [exec iverilog -o testbench.out "$output_dir/${mod_name}_tb.v"]
#    set sim_out [exec vvp testbench.out]
#    log_message "$sim_out"
#}
#pack .b4 -pady 5

