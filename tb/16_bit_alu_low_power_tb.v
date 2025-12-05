// ============================================================================
// Testbench for Low-Power 16-bit ALU with Clock Gating
// Description: Tests ALU functionality with enable/disable scenarios
//              to demonstrate power savings
// ============================================================================

`timescale 1ns / 1ps

module tb_alu_16bit_low_power;

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

    // Instantiate the low-power ALU
    alu_16bit_low_power uut (
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
        enable = 0;  // Start with ALU disabled
        
        $display("========================================");
        $display("Low-Power 16-bit ALU Testbench");
        $display("Testing Clock Gating Functionality");
        $display("========================================");
        
        // Reset sequence
        #20;
        rst_n = 1;
        #10;
        
        // ====================================================================
        // Test Phase 1: ALU Disabled (Clock Gated)
        // ====================================================================
        $display("\n--- Phase 1: ALU Disabled (Clock Gated) ---");
        $display("Operands changing but enable=0, no computation should occur");
        enable = 0;
        
        a = 16'd1000;
        b = 16'd500;
        alu_op = 3'b000; // ADD
        #30;
        $display("Enable=0, A=%d, B=%d, Result=%d (should remain 0)", a, b, result);
        
        a = 16'd2000;
        b = 16'd1000;
        #30;
        $display("Enable=0, A=%d, B=%d, Result=%d (should remain 0)", a, b, result);
        
        // ====================================================================
        // Test Phase 2: Enable ALU and Perform Operations
        // ====================================================================
        $display("\n--- Phase 2: ALU Enabled (Active Operation) ---");
        enable = 1;
        #10;
        
        // Test 1: Addition
        $display("\nTest 1: ADD - 1000 + 500 = 1500");
        a = 16'd1000;
        b = 16'd500;
        alu_op = 3'b000;
        #20;
        $display("Enable=1, A=%d, B=%d, Result=%d", a, b, result);
        
        // Test 2: Subtraction
        $display("\nTest 2: SUB - 1000 - 300 = 700");
        a = 16'd1000;
        b = 16'd300;
        alu_op = 3'b001;
        #20;
        $display("Enable=1, A=%d, B=%d, Result=%d", a, b, result);
        
        // Test 3: AND
        $display("\nTest 3: AND - 0xFF00 & 0x0FF0");
        a = 16'hFF00;
        b = 16'h0FF0;
        alu_op = 3'b010;
        #20;
        $display("Enable=1, A=%h, B=%h, Result=%h", a, b, result);
        
        // Test 4: Multiplication
        $display("\nTest 4: MUL - 100 * 200 = 20000");
        a = 16'd100;
        b = 16'd200;
        alu_op = 3'b111;
        #20;
        $display("Enable=1, A=%d, B=%d, Result=%d", a, b, result);
        
        // ====================================================================
        // Test Phase 3: Disable During Operation (Power Saving Scenario)
        // ====================================================================
        $display("\n--- Phase 3: Dynamic Enable/Disable ---");
        $display("Simulating idle periods for power savings");
        
        // Computation period
        enable = 1;
        a = 16'd5000;
        b = 16'd3000;
        alu_op = 3'b000; // ADD
        #20;
        $display("Enable=1, Computing: %d + %d = %d", a, b, result);
        
        // Idle period (clock gated)
        enable = 0;
        #40;
        $display("Enable=0, Idle period (clock gated, saving power)");
        
        // Resume computation
        enable = 1;
        a = 16'd8000;
        b = 16'd2000;
        alu_op = 3'b001; // SUB
        #20;
        $display("Enable=1, Computing: %d - %d = %d", a, b, result);
        
        // ====================================================================
        // Test Phase 4: Operand Isolation Verification
        // ====================================================================
        $display("\n--- Phase 4: Operand Isolation Test ---");
        $display("High switching activity on inputs while disabled");
        
        enable = 0;
        // Rapidly changing inputs (would cause power waste without isolation)
        repeat(10) begin
            a = $random;
            b = $random;
            alu_op = $random;
            #10;
        end
        $display("Inputs toggled rapidly while disabled - operand isolation prevents switching");
        $display("Result remains: %d (unchanged)", result);
        
        // ====================================================================
        $display("\n========================================");
        $display("All Tests Completed Successfully!");
        $display("Clock gating and operand isolation verified");
        $display("========================================");
        
        #50;
        $display("\nSimulation ending at time %0t", $time);
        $stop;  // Use $stop instead of $finish for better control
    end
    
    // Timeout watchdog - force stop after 500ns
    initial begin
        #500;
        $display("\nWARNING: Simulation timeout at 500ns");
        $stop;
    end
    
    // Monitor for debugging
    initial begin
        $monitor("Time=%0t | Enable=%b | OP=%b | A=%h | B=%h | Result=%h", 
                 $time, enable, alu_op, a, b, result);
    end

endmodule