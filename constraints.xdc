# ============================================================================
# Timing Constraints for 16-bit ALU
# Target: Artix-7 FPGA (xc7a35tcpg236-1)
# Clock Frequency: 100 MHz (10ns period)
# ============================================================================

# Create clock constraint - 100MHz
create_clock -period 10.000 -name clk -waveform {0.000 5.000} [get_ports clk]

# Input delays (assume 2ns from external source)
set_input_delay -clock clk -min 0.000 [get_ports {a[*] b[*] alu_op[*] enable rst_n}]
set_input_delay -clock clk -max 2.000 [get_ports {a[*] b[*] alu_op[*] enable rst_n}]

# Output delays (assume 2ns to external destination)
set_output_delay -clock clk -min 0.000 [get_ports {result[*] zero_flag carry_flag}]
set_output_delay -clock clk -max 2.000 [get_ports {result[*] zero_flag carry_flag}]