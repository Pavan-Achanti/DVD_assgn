# 4-bit Array Multiplier

## Team members

1. Name: <Dhriti Sharma>
   Roll number: <2026203015>

2. Name: <>
   Roll number: <>

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
