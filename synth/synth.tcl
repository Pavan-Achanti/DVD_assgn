
# synth/synth.tcl
# Part B: Logic synthesis using Yosys and the SKY130 HD library

# Set the path to the typical-corner Liberty timing library
set lib "$::env(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

# Step 1: Read the Verilog design files
yosys read_verilog rtl/full_adder.v rtl/mult_array.v

# Step 2: Synthesize the design and flatten the full-adder instances
yosys synth -top mult_array -flatten

# Step 3: Map flip-flops to SKY130 standard cells
yosys dfflibmap -liberty $lib

# Step 4: Map combinational logic to SKY130 standard cells
yosys abc -liberty $lib

# Step 5: Remove unused wires and cells
yosys opt_clean -purge

# Step 6: Generate the cell statistics and area report
yosys tee -o synth/mult_array_stat.rpt stat -liberty $lib

# Step 7: Write the gate-level Verilog netlist
yosys write_verilog -noattr synth/mult_array_netlist.v
