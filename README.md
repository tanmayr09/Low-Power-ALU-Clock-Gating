# Low-Power 16-bit ALU with Clock Gating

A power-optimized 16-bit ALU designed in Verilog HDL with clock gating techniques for reducing dynamic power consumption.

## Overview

This project implements a 16-bit Arithmetic Logic Unit supporting 8 operations. The main focus is on power optimization using clock gating and operand isolation techniques. The design was synthesized on Xilinx Artix-7 FPGA and analyzed for power consumption.

## Features

- 8 arithmetic and logical operations: ADD, SUB, AND, OR, XOR, SHL, SHR, MUL
- Clock gating using integrated clock gating (ICG) cells
- Operand isolation to reduce switching activity
- Status flags (zero flag, carry flag)
- 100 MHz operation

## Project Structure

```
├── rtl/
│   ├── 16_bit_alu_low_power.v      # Clock-gated ALU
│   └── basic_16_bit_alu.v          # Basic ALU (for comparison)
├── tb/
│   ├── 16_bit_alu_low_power_tb.v   # Testbench for clock-gated version
│   └── basic_16_bit_alu_tb.v       # Testbench for basic version
├── docs/
│   └── Design_Concepts.md          # Detailed design methodology and concepts
├── waveforms/
│   ├── README.md                   # Waveform documentation
│   ├── baseline_power_report.png   # Basic ALU power report
│   ├── basic_16_bit_alu.png        # Basic ALU simulation waveform
│   ├── low_power_16_bit_alu.png    # Clock-gated ALU waveform
│   └── low_power_alu_power_report.png  # Clock-gated ALU power report
├── constraints.xdc                  # Timing constraints (100 MHz)
├── .gitignore                       # Git ignore file
└── README.md                        # This file
```

## How It Works

### Clock Gating
When the ALU is disabled (enable = 0), the clock signal is gated to save power:
- Clock tree stops switching
- Registers don't toggle unnecessarily
- Reduces dynamic power consumption

### Operand Isolation
Input operands are forced to zero when the ALU is disabled:
```verilog
assign a_isolated = enable ? a : 16'b0;
assign b_isolated = enable ? b : 16'b0;
```
This prevents switching in the combinational logic (adders, multipliers, shifters).

## Operations

| Operation | Code | Description |
|-----------|------|-------------|
| ADD | 000 | Addition |
| SUB | 001 | Subtraction |
| AND | 010 | Bitwise AND |
| OR | 011 | Bitwise OR |
| XOR | 100 | Bitwise XOR |
| SHL | 101 | Shift left |
| SHR | 110 | Shift right |
| MUL | 111 | Multiplication |

## Power Analysis

Synthesized on Artix-7 FPGA (xc7a35tcpg236-1) at 100 MHz:

- **Basic ALU**: 84 mW total power (14 mW dynamic)
- **Clock-Gated ALU**: 83 mW total power (12 mW dynamic)
- **Estimated savings with 50% duty cycle**: ~30-35% reduction in dynamic power

The clock gating technique is most effective when the ALU has idle periods. With realistic usage patterns (50% enable duty cycle), the dynamic power savings are significant.

## Simulation

To run the simulation in Vivado:
1. Create a new project and add the source files
2. Add the appropriate testbench as simulation source
3. Run Behavioral Simulation
4. Check the waveforms and console output

The testbench verifies:
- All 8 operations work correctly
- Clock gating prevents switching when enable = 0
- Operand isolation stops logic from toggling during idle periods

## Documentation

For detailed explanations of design concepts and implementation:
- [Design Concepts](docs/Design_Concepts.md) - Theoretical background and methodology
- [Waveforms](waveforms/) - Simulation results and verification

## Results

- Functional verification: All operations tested and working
- Synthesis: Successfully synthesized on Artix-7
- Power analysis: Dynamic power identified as main contributor
- Clock gating reduces switching activity during idle cycles

## Tools Used

- Xilinx Vivado (synthesis and power analysis)
- Verilog HDL
- Target: Artix-7 FPGA

## Future Improvements

- Add more operations (division, rotation)
- Implement pipelining for better throughput
- Use SAIF files for more accurate power analysis
- Test on actual hardware