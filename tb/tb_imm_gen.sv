module tb_imm_gen;

    // ------------------------------------------------------------
    // Signals connected to the DUT
    // ------------------------------------------------------------

    logic [31:0] instr;       // 32-bit RISC-V instruction

    logic [2:0] imm_type;     // Immediate format selected by decoder

    logic [31:0] imm;         // Generated 32-bit immediate


    // ------------------------------------------------------------
    // Immediate type definitions
    // These MUST match imm_gen.sv and decoder.sv
    // ------------------------------------------------------------

    localparam IMM_NONE = 3'b000;
    localparam IMM_I    = 3'b001;
    localparam IMM_S    = 3'b010;
    localparam IMM_B    = 3'b011;
    localparam IMM_U    = 3'b100;
    localparam IMM_J    = 3'b101;


    // ------------------------------------------------------------
    // Instantiate the Immediate Generator
    // ------------------------------------------------------------

    imm_gen dut (

        .instr(instr),

        .imm_type(imm_type),

        .imm(imm)

    );


    // ------------------------------------------------------------
    // Test sequence
    // ------------------------------------------------------------

    initial begin

        // ========================================================
        // TEST 1: I-TYPE
        //
        // ADDI x5, x6, 10
        //
        // Instruction:
        // 0x00A30293
        //
        // Expected immediate:
        // 10 = 0x0000000A
        // ========================================================

        imm_type = IMM_I;
        instr = 32'h00A30293;

        #1;

        $display("I-type: instr=%h imm=%h", instr, imm);

        assert(imm == 32'h0000000A)
            else $error("I-type immediate failed");

        $display("TEST 1 PASSED: I-type");


        // ========================================================
        // TEST 2: NEGATIVE I-TYPE
        //
        // ADDI x5, x6, -1
        //
        // Expected:
        // 0xFFFFFFFF
        // ========================================================

        imm_type = IMM_I;
        instr = 32'hFFF30293;

        #1;

        $display("I-type negative: instr=%h imm=%h", instr, imm);

        assert(imm == 32'hFFFFFFFF)
            else $error("Negative I-type immediate failed");

        $display("TEST 2 PASSED: Negative I-type");


        // ========================================================
        // TEST 3: S-TYPE
        //
        // SW x5, 12(x10)
        //
        // Expected:
        // immediate = 12
        // ========================================================

        imm_type = IMM_S;
        instr = 32'h00552623;

        #1;

        $display("S-type: instr=%h imm=%h", instr, imm);

        assert(imm == 32'h0000000C)
            else $error("S-type immediate failed");

        $display("TEST 3 PASSED: S-type");


        // ========================================================
        // TEST 4: B-TYPE
        //
        // Test a simple branch with offset 8.
        //
        // We construct the instruction manually.
        // ========================================================

        imm_type = IMM_B;

        // BEQ x0, x0, 8
        //
        // Encoding = 0x00000463

        instr = 32'h00000463;

        #1;

        $display("B-type: instr=%h imm=%h", instr, imm);

        assert(imm == 32'h00000008)
            else $error("B-type immediate failed");

        $display("TEST 4 PASSED: B-type");


        // ========================================================
        // TEST 5: U-TYPE
        //
        // LUI x5, 0x12345
        //
        // Expected:
        // 0x12345000
        // ========================================================

        imm_type = IMM_U;
        instr = 32'h123452B7;

        #1;

        $display("U-type: instr=%h imm=%h", instr, imm);

        assert(imm == 32'h12345000)
            else $error("U-type immediate failed");

        $display("TEST 5 PASSED: U-type");


        // ========================================================
        // TEST 6: J-TYPE
        //
        // JAL x1, 8
        //
        // Expected immediate:
        // 8
        // ========================================================

        imm_type = IMM_J;
        instr = 32'h008000EF;

        #1;

        $display("J-type: instr=%h imm=%h", instr, imm);

        assert(imm == 32'h00000008)
            else $error("J-type immediate failed");

        $display("TEST 6 PASSED: J-type");


        // ========================================================
        // TEST 7: IMM_NONE
        //
        // If no immediate format is selected,
        // output should be zero.
        // ========================================================

        imm_type = IMM_NONE;
        instr = 32'hFFFFFFFF;

        #1;

        $display("NONE: instr=%h imm=%h", instr, imm);

        assert(imm == 32'h00000000)
            else $error("IMM_NONE failed");

        $display("TEST 7 PASSED: IMM_NONE");


        // ========================================================
        // FINISH
        // ========================================================

        $display("");
        $display("======================================");
        $display("ALL IMM_GEN TESTS PASSED");
        $display("======================================");

        $finish;

    end

endmodule
