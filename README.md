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

# Part D: Physical Design of a 4-Bit Array Multiplier Using LibreLane

## 1. Objective

The objective of Part D was to perform the physical design of the 4-bit array multiplier using LibreLane and the SKY130 standard-cell library. The flow included floorplanning, placement, clock-tree synthesis, routing, timing analysis, DRC, and LVS. Two runs were performed, using clock periods of 3.5 ns and 4.0 ns, to evaluate timing and physical implementation results.

## 2. Design Configuration

The design was implemented using the following configuration:

| Parameter | Value |
|---|---|
| Design name | `mult_array` |
| PDK | SKY130A |
| Standard-cell library | SKY130 HD |
| Clock port | `clk` |
| Initial clock period | 3.5 ns |
| Final clock period | 4.0 ns |
| Floorplan sizing mode | Absolute |
| Die area | 150 × 150 µm² |

The configuration file is `config.json`, located in the `pnr` directory. The RTL source files used were `full_adder.v` and `mult_array.v`.

The relevant configuration entries were:

```json
{
  "DESIGN_NAME": "mult_array",
  "VERILOG_FILES": [
    "dir::../rtl/full_adder.v",
    "dir::../rtl/mult_array.v"
  ],
  "CLOCK_PORT": "clk",
  "CLOCK_PERIOD": 4.0,
  "FP_SIZING": "absolute",
  "DIE_AREA": [0, 0, 150, 150]
}
```

For the first run, `CLOCK_PERIOD` was set to `3.5`. It was subsequently changed to `4.0` for the second run.

## 3. Commands Used

The physical-design flow was executed from the `pnr` directory.

### Run 1: Clock Period of 3.5 ns

```bash
cd pnr
```

Set `CLOCK_PERIOD` to `3.5` in `config.json`, then execute:

```bash
librelane config.json
```

This run completed the physical-design flow. However, the worst setup slack at the slow corner was negative, indicating a setup-timing violation.

### Run 2: Clock Period of 4.0 ns

Change the clock period in `config.json` to `4.0`, then execute:

```bash
librelane config.json
```

The second run completed with positive worst setup slack and no reported setup violations across the fast, typical, and slow corners.



## 4. Results and Comparison


| Metric | Run 1: 3.5 ns | Run 2: 4.0 ns |
|---|---:|---:|
| Clock period | 3.5 ns | 4.0 ns |
| Worst setup slack at slow corner | −0.010826 ns | +0.096035 ns |
| Setup timing violations | Timing violation present | 0 across all reported corners |
| DRC violations | 0 | 0 |
| LVS violations | 0 | 0 |
| Hold buffers | 4 | 3 |
| Fill cells | 1,208 | 1,209 |
| Standard cells after place and route | 121 | 121 |
| Final routed wirelength | 2985 µm | 2,979 µm |

The 3.5 ns run completed with a worst setup slack of −0.010826 ns, corresponding to a small setup-timing violation. Increasing the clock period to 4.0 ns improved the timing margin, producing a worst setup slack of +0.096035 ns and eliminating the reported setup violations.

The final routed wirelength for the 4.0 ns run was 2,979 µm. The flow also inserted buffers and fill cells as part of timing repair, clock distribution, hold-time correction, and physical-layout requirements.

## 5. Post-Route Frequency Estimate

The estimated post-route maximum frequency was calculated using:

$$
F_{\max,\mathrm{post}} = \frac{1000}{T_{\mathrm{clock}}-\mathrm{WNS}}
$$

where the clock period and worst setup slack (WNS) are expressed in nanoseconds.

For the 4.0 ns run:

$$
T_{\min,\mathrm{post}} = 4.0 - 0.096035 = 3.903965\ \text{ns}
$$

Therefore,

$$
F_{\max,\mathrm{post}} = \frac{1000}{3.903965} \approx 256.15\ \text{MHz}
$$

The estimated maximum frequency after physical implementation is approximately **256.15 MHz**, compared with the Part C estimate of **384.02 MHz**. The reduction is consistent with the additional timing effects introduced by physical implementation, including routing parasitics and inserted cells.

The 3.5 ns run had negative setup slack, so its nominal clock period should not be interpreted as a timing-clean operating point.

## 6. Physical Verification

The final 4.0 ns run reported zero DRC violations,  and zero LVS violations.

Design Rule Checking verifies that the physical layout satisfies the applicable geometric and manufacturing rules. Layout Versus Schematic (LVS) checks whether the electrical connectivity extracted from the layout matches the intended circuit netlist. Passing both checks provides evidence that the layout is geometrically compliant and electrically consistent with the design.

## 7. Layout Inspection

The final GDS file was opened in KLayout for visual inspection. Two screenshots were captured:

1. **Full-chip view:** Shows the overall die boundary and the placement of the design within the floorplan.
2. **Zoomed layout view:** Shows the standard-cell rows and metal routing in greater detail.

The screenshots are included with the Part D submission as evidence of the completed physical layout in the report

## 8. Final Output

The 4.0 ns run was selected as the final implementation because it completed with positive worst setup slack and zero reported setup violations across all timing corners. Its GDS file, metrics, and layout screenshots were used for the final submission.

The principal results of the final run were:

- Clock period: 4.0 ns
- Worst setup slack: +0.096035 ns
- Estimated post-route maximum frequency: 256.15 MHz
- Standard cells after place and route: 121
- Final routed wirelength: 2,979 µm
- DRC violations: 0
- LVS violations: 0
