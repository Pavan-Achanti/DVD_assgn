# 4-bit Array Multiplier

## Team members

1. Name: Dhriti Sharma
   Roll number: 2026203015 

2. Name: Achanti Pavan Kumar   
   Roll number: 2026203016

## Design

A 4-bit unsigned array multiplier with an 8-bit registered output.

The design contains:
- 16 AND gates for partial products.
- 12 full-adder instances.
- Registered inputs and output.
- Asynchronous active-low reset.
- Two-cycle input-to-output latency.

## Part A: RTL design and verification

### Compile

```bash
iverilog -g2012 -o sim tb/tb_mult.v rtl/full_adder.v rtl/mult_array.v
# DVD_assgn
DVD rtl to gds assignment
 557fde96eed43430f26d63f4d876ef070358be04
```
## Part B: Logic Synthesis with Yosys

| Metric                        | Value |
|-------------------------------|-------------|
| Total number of cells         | 63          |
| Number of flip-flops          | 16          |
| Total cell area               | 740.7104 µm² |
| Flip-flop area                | 400.384 µm² |
| Flip-flop area (% of total)   | 54.05%      |
| Netlist simulation result     | PASS: 256 vectors checked, 0 errors      |
### Three most-used cell types
| Cell type                    | Count |
|------------------------------|------:|
| `sky130_fd_sc_hd__dfrtp_1`   | 16    |
| `sky130_fd_sc_hd__nand2_1`   | 8     |
| `sky130_fd_sc_hd__a21oi_1`   | 6     |

The dfrtp_1 cells are flip-flops with an active-low asynchronous reset. The nand2_1 cells are two-input NAND gates, and a21oi_1 cells implement an AND-OR-invert logic function.
