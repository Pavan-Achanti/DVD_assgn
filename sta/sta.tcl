# Part C: Static Timing Analysis using OpenSTA

# 1. Select the typical SKY130 HD timing library
set lib "$::env(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

# 2. Set the clock period in nanoseconds
# First run: 10 ns
set clock_period 2.60

# 3. Read the standard-cell timing library
read_liberty $lib

# 4. Read the synthesized gate-level netlist from Part B
read_verilog synth/mult_array_netlist.v

# 5. Link the design
link_design mult_array

# 6. Define the clock on the clk input
create_clock -name clk -period $clock_period [get_ports clk]

# 7. Define external input arrival delays
set_input_delay 1.0 -clock clk \
    [delete_from_list [all_inputs] [get_ports clk]]

# 8. Define external output delays
set_output_delay 1.0 -clock clk [all_outputs]

# 9. Report the worst setup slack
report_worst_slack -max

# 10. Save the maximum-delay timing paths to a report
report_checks -path_delay max -digits 3 > sta/mult_array_timing.rpt

