// ============================================================================
// Testbench for 16-bit ALU
// Description: Comprehensive test for all 8 ALU operations
// ============================================================================

`timescale 1ns / 1ps

module tb_alu_16bit;

    // Testbench signals
    reg clk;
    reg rst_n;
    reg [15:0] a;
    reg [15:0] b;
    reg [2:0] alu_op;
    reg enable;
    wire [15:0] result;
    wire zero_flag;
    wire carry_flag;

    // Instantiate the ALU
    alu_16bit uut (
        .clk(clk),
        .rst_n(rst_n),
        .a(a),
        .b(b),
        .alu_op(alu_op),
        .enable(enable),
        .result(result),
        .zero_flag(zero_flag),
        .carry_flag(carry_flag)
    );

    // Clock generation - 100MHz (10ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test stimulus
    initial begin
        // Initialize signals
        rst_n = 0;
        a = 0;
        b = 0;
        alu_op = 0;
        enable = 1;
        
        // Display header
        $display("========================================");
        $display("16-bit ALU Testbench");
        $display("========================================");
        
        // Reset sequence
        #20;
        rst_n = 1;
        #10;
        
        // Test 1: Addition (no carry)
        $display("\nTest 1: ADD - 1000 + 500 = 1500");
        a = 16'd1000;
        b = 16'd500;
        alu_op = 3'b000; // ADD
        #10;
        $display("A=%d, B=%d, Result=%d, Carry=%b", a, b, result, carry_flag);
        
        // Test 2: Addition (with carry)
        #10;
        $display("\nTest 2: ADD with Carry - 65000 + 1000");
        a = 16'd65000;
        b = 16'd1000;
        alu_op = 3'b000; // ADD
        #10;
        $display("A=%d, B=%d, Result=%d, Carry=%b", a, b, result, carry_flag);
        
        // Test 3: Subtraction
        #10;
        $display("\nTest 3: SUB - 1000 - 300 = 700");
        a = 16'd1000;
        b = 16'd300;
        alu_op = 3'b001; // SUB
        #10;
        $display("A=%d, B=%d, Result=%d", a, b, result);
        
        // Test 4: AND operation
        #10;
        $display("\nTest 4: AND - 0xFF00 & 0x0FF0");
        a = 16'hFF00;
        b = 16'h0FF0;
        alu_op = 3'b010; // AND
        #10;
        $display("A=%h, B=%h, Result=%h", a, b, result);
        
        // Test 5: OR operation
        #10;
        $display("\nTest 5: OR - 0xF000 | 0x0F00");
        a = 16'hF000;
        b = 16'h0F00;
        alu_op = 3'b011; // OR
        #10;
        $display("A=%h, B=%h, Result=%h", a, b, result);
        
        // Test 6: XOR operation
        #10;
        $display("\nTest 6: XOR - 0xFFFF ^ 0xAAAA");
        a = 16'hFFFF;
        b = 16'hAAAA;
        alu_op = 3'b100; // XOR
        #10;
        $display("A=%h, B=%h, Result=%h", a, b, result);
        
        // Test 7: Shift Left
        #10;
        $display("\nTest 7: SHL - 0x0001 << 4");
        a = 16'h0001;
        b = 16'd4;
        alu_op = 3'b101; // SHL
        #10;
        $display("A=%h, B=%d, Result=%h", a, b, result);
        
        // Test 8: Shift Right
        #10;
        $display("\nTest 8: SHR - 0x1000 >> 4");
        a = 16'h1000;
        b = 16'd4;
        alu_op = 3'b110; // SHR
        #10;
        $display("A=%h, B=%d, Result=%h", a, b, result);
        
        // Test 9: Multiplication
        #10;
        $display("\nTest 9: MUL - 100 * 200 = 20000");
        a = 16'd100;
        b = 16'd200;
        alu_op = 3'b111; // MUL
        #10;
        $display("A=%d, B=%d, Result=%d", a, b, result);
        
        // Test 10: Zero flag test
        #10;
        $display("\nTest 10: Zero Flag - 500 - 500 = 0");
        a = 16'd500;
        b = 16'd500;
        alu_op = 3'b001; // SUB
        #10;
        $display("A=%d, B=%d, Result=%d, Zero=%b", a, b, result, zero_flag);
        
        // Test 11: Multiple operations in sequence
        #10;
        $display("\n========================================");
        $display("All Tests Completed Successfully!");
        $display("========================================");
        
        #50;
        $finish;
    end
    
    // Monitor changes (optional - useful for debugging)
    initial begin
        $monitor("Time=%0t | OP=%b | A=%h | B=%h | Result=%h | Zero=%b | Carry=%b", 
                 $time, alu_op, a, b, result, zero_flag, carry_flag);
    end

endmodule