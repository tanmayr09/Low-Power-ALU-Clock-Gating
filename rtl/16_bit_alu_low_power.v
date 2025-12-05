// ============================================================================
// Low-Power 16-bit ALU with Clock Gating and Operand Isolation
// Description: Power-optimized ALU using fine-grained clock gating and 
//              operand isolation to reduce dynamic switching power
// Power Optimization Techniques:
//   1. Integrated Clock Gating (ICG) cells to gate clock when ALU is disabled
//   2. Operand isolation to prevent unnecessary switching in downstream logic
// ============================================================================

module alu_16bit_low_power (
    input wire clk,              // Main clock signal
    input wire rst_n,            // Active-low reset
    input wire [15:0] a,         // Operand A
    input wire [15:0] b,         // Operand B
    input wire [2:0] alu_op,     // ALU operation select
    input wire enable,           // Enable signal for clock gating
    output reg [15:0] result,    // ALU result
    output reg zero_flag,        // Zero flag (result == 0)
    output reg carry_flag        // Carry flag for arithmetic operations
);

    // Operation codes
    localparam OP_ADD  = 3'b000;
    localparam OP_SUB  = 3'b001;
    localparam OP_AND  = 3'b010;
    localparam OP_OR   = 3'b011;
    localparam OP_XOR  = 3'b100;
    localparam OP_SHL  = 3'b101;
    localparam OP_SHR  = 3'b110;
    localparam OP_MUL  = 3'b111;

    // Clock gating signals
    wire gated_clk;              // Gated clock output from ICG cell
    
    // Operand isolation - isolated inputs to prevent switching
    wire [15:0] a_isolated;
    wire [15:0] b_isolated;
    
    // Internal computation signals
    reg [16:0] temp_result;
    reg [31:0] mul_result;

    // ========================================================================
    // POWER OPTIMIZATION 1: Integrated Clock Gating (ICG) Cell
    // ========================================================================
    // ICG cell gates the clock when enable=0, reducing dynamic power
    // This prevents unnecessary clock tree switching and register toggling
    
    icg_cell u_icg (
        .clk_in(clk),
        .enable(enable),
        .clk_out(gated_clk)
    );

    // ========================================================================
    // POWER OPTIMIZATION 2: Operand Isolation
    // ========================================================================
    // When ALU is disabled, force operands to 0 to prevent switching activity
    // in the combinational logic (adders, multipliers, shifters)
    // This reduces dynamic power in the datapath
    
    assign a_isolated = enable ? a : 16'b0;
    assign b_isolated = enable ? b : 16'b0;

    // ========================================================================
    // Main ALU Logic (now using gated clock and isolated operands)
    // ========================================================================
    
    always @(posedge gated_clk or negedge rst_n) begin
        if (!rst_n) begin
            result <= 16'b0;
            zero_flag <= 1'b0;
            carry_flag <= 1'b0;
        end else begin
            // Default values
            carry_flag <= 1'b0;
            
            case (alu_op)
                OP_ADD: begin
                    temp_result = {1'b0, a_isolated} + {1'b0, b_isolated};
                    result <= temp_result[15:0];
                    carry_flag <= temp_result[16];
                end
                
                OP_SUB: begin
                    temp_result = {1'b0, a_isolated} - {1'b0, b_isolated};
                    result <= temp_result[15:0];
                    carry_flag <= temp_result[16];
                end
                
                OP_AND: begin
                    result <= a_isolated & b_isolated;
                end
                
                OP_OR: begin
                    result <= a_isolated | b_isolated;
                end
                
                OP_XOR: begin
                    result <= a_isolated ^ b_isolated;
                end
                
                OP_SHL: begin
                    result <= a_isolated << b_isolated[3:0];
                end
                
                OP_SHR: begin
                    result <= a_isolated >> b_isolated[3:0];
                end
                
                OP_MUL: begin
                    mul_result = a_isolated * b_isolated;
                    result <= mul_result[15:0];
                end
                
                default: begin
                    result <= 16'b0;
                end
            endcase
            
            // Set zero flag
            zero_flag <= (result == 16'b0);
        end
    end

endmodule


// ============================================================================
// Integrated Clock Gating (ICG) Cell
// Description: Standard ICG cell with latch-based enable
//              Prevents glitches and ensures clean clock gating
// ============================================================================

module icg_cell (
    input wire clk_in,      // Input clock
    input wire enable,      // Enable signal (active high)
    output wire clk_out     // Gated clock output
);

    reg enable_latched;
    
    // Latch enable on negative edge to avoid glitches
    // This is a standard clock gating technique
    always @(clk_in or enable) begin
        if (!clk_in) begin
            enable_latched <= enable;
        end
    end
    
    // Gate the clock: only pass clock when enabled
    assign clk_out = clk_in & enable_latched;

endmodule