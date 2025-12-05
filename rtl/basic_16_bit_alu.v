// ============================================================================
// 16-bit ALU with 8 Operations
// Description: Basic ALU supporting arithmetic and logical operations
// Operations: ADD, SUB, AND, OR, XOR, SHL, SHR, MUL
// ============================================================================

module alu_16bit (
    input wire clk,              // Clock signal
    input wire rst_n,            // Active-low reset
    input wire [15:0] a,         // Operand A
    input wire [15:0] b,         // Operand B
    input wire [2:0] alu_op,     // ALU operation select
    input wire enable,           // Enable signal for clock gating (we'll use this later)
    output reg [15:0] result,    // ALU result
    output reg zero_flag,        // Zero flag (result == 0)
    output reg carry_flag        // Carry flag for arithmetic operations
);

    // Operation codes
    localparam OP_ADD  = 3'b000;  // Addition
    localparam OP_SUB  = 3'b001;  // Subtraction
    localparam OP_AND  = 3'b010;  // Bitwise AND
    localparam OP_OR   = 3'b011;  // Bitwise OR
    localparam OP_XOR  = 3'b100;  // Bitwise XOR
    localparam OP_SHL  = 3'b101;  // Shift left
    localparam OP_SHR  = 3'b110;  // Shift right
    localparam OP_MUL  = 3'b111;  // Multiplication (lower 16 bits)

    // Internal signals
    reg [16:0] temp_result;  // 17-bit for carry detection
    reg [31:0] mul_result;   // 32-bit for multiplication

    // Main ALU logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            result <= 16'b0;
            zero_flag <= 1'b0;
            carry_flag <= 1'b0;
        end else begin
            // Default values
            carry_flag <= 1'b0;
            
            case (alu_op)
                OP_ADD: begin
                    temp_result = {1'b0, a} + {1'b0, b};
                    result <= temp_result[15:0];
                    carry_flag <= temp_result[16];  // Carry out
                end
                
                OP_SUB: begin
                    temp_result = {1'b0, a} - {1'b0, b};
                    result <= temp_result[15:0];
                    carry_flag <= temp_result[16];  // Borrow
                end
                
                OP_AND: begin
                    result <= a & b;
                end
                
                OP_OR: begin
                    result <= a | b;
                end
                
                OP_XOR: begin
                    result <= a ^ b;
                end
                
                OP_SHL: begin
                    result <= a << b[3:0];  // Shift by lower 4 bits of b
                end
                
                OP_SHR: begin
                    result <= a >> b[3:0];  // Shift by lower 4 bits of b
                end
                
                OP_MUL: begin
                    mul_result = a * b;
                    result <= mul_result[15:0];  // Lower 16 bits only
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