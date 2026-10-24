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

## Part C: Static Timing Analysis Using OpenSTA

### Procedure

1. Loaded the SKY130 HD typical-corner Liberty timing library.
2. Read the synthesized gate-level netlist generated in Part B.
3. Linked the `mult_array` design.
4. Defined a 10 ns clock and input/output timing constraints.
5. Ran OpenSTA and examined the timing report.
6. Calculated the estimated minimum clock period using `Tmin = T - WNS`.
7. Calculated the estimated maximum frequency using `Fmax = 1000 / Tmin`.
8. Reran OpenSTA with the minimum period rounded to 2.60 ns.
9. Recorded the critical path and its standard-cell instances.

### First timing run: 10 ns

| Metric | Result |
|---|---:|
| Clock period | 10 ns |
| Data arrival time | 2.471 ns |
| Data required time | 9.866 ns |
| Reported register-to-register setup slack | 7.396 ns |
| Reset recovery slack | 9.228 ns |
| Critical-path startpoint | `_095_` |
| Critical-path endpoint | `_092_` |

### Calculated timing results

Minimum clock period:

`Tmin = 10 - 7.396 = 2.604 ns`

Rounded minimum clock period:

`Tmin = 2.60 ns`

Estimated maximum frequency:

`Fmax = 1000 / 2.604 = 384.02 MHz`

### Second timing run: 2.60 ns

| Metric | Result |
|---|---|
| Clock period | 2.60 ns |
| Register-to-register setup slack | [Insert measured result] |

### Critical-path analysis

The first timing report identified a register-to-register path from `_095_` to `_092_`.

The mapped path contains a flip-flop, inverter, complex logic cells, majority cells, and XNOR cells. The reported data arrival time was 2.471 ns, the data required time was 9.866 ns, and the setup slack was 7.396 ns.

The original full adders were flattened during synthesis, so the report lists mapped standard-cell instances rather than named full-adder instances.

For a 4-bit multiplier, the approximate architectural estimate is `2N = 8` full-adder delays. This estimate should be compared with the logic on the measured critical path.

### Commands used

1. `sta -version`
2. `sta -exit sta/sta.tcl 2>&1 | tee sta/run_10ns.log`
3. `cp sta/mult_array_timing.rpt sta/mult_array_timing_10ns.rpt`
4. `sta -exit sta/sta.tcl 2>&1 | tee sta/run_tmin.log`
5. `cat sta/mult_array_timing.rpt`
