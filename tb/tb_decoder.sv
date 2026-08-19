module tb_decoder;

    logic [31:0] instr;

    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] rd;

    logic [2:0] funct3;
    logic [6:0] funct7;

    logic [2:0] imm_type;
    logic [3:0] alu_op;

    logic is_rtype;
    logic is_itype;
    logic is_load;
    logic is_store;
    logic is_branch;
    logic is_jal;
    logic is_jalr;
    logic is_lui;
    logic is_auipc;


    decoder dut (
        .instr(instr),

        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),

        .funct3(funct3),
        .funct7(funct7),

        .imm_type(imm_type),
        .alu_op(alu_op),

        .is_rtype(is_rtype),
        .is_itype(is_itype),
        .is_load(is_load),
        .is_store(is_store),
        .is_branch(is_branch),
        .is_jal(is_jal),
        .is_jalr(is_jalr),
        .is_lui(is_lui),
        .is_auipc(is_auipc)
    );


    // ------------------------------------------------------------
    // ALU operation constants
    // These must match decoder.sv
    // ------------------------------------------------------------

    localparam ALU_ADD = 4'b0000;
    localparam ALU_SUB = 4'b0001;
    localparam ALU_AND = 4'b0010;
    localparam ALU_OR  = 4'b0011;
    localparam ALU_XOR = 4'b0100;


    // ------------------------------------------------------------
    // Immediate type constants
    // ------------------------------------------------------------

    localparam IMM_NONE = 3'b000;
    localparam IMM_I    = 3'b001;
    localparam IMM_S    = 3'b010;
    localparam IMM_B    = 3'b011;
    localparam IMM_U    = 3'b100;
    localparam IMM_J    = 3'b101;


    initial begin

        // ========================================================
        // TEST 1
        // ADD x5, x6, x7
        //
        // Machine code:
        // 0x007302B3
        // ========================================================

        instr = 32'h007302B3;
        #1;

        assert(rs1 == 5'd6)
            else $error("ADD: rs1 incorrect");

        assert(rs2 == 5'd7)
            else $error("ADD: rs2 incorrect");

        assert(rd == 5'd5)
            else $error("ADD: rd incorrect");

        assert(is_rtype == 1'b1)
            else $error("ADD: R-type not detected");

        assert(alu_op == ALU_ADD)
            else $error("ADD: ALU operation incorrect");

        $display("TEST 1 PASSED: ADD");


        // ========================================================
        // TEST 2
        // SUB x5, x6, x7
        //
        // Machine code:
        // 0x407302B3
        // ========================================================

        instr = 32'h407302B3;
        #1;

        assert(is_rtype == 1'b1)
            else $error("SUB: R-type not detected");

        assert(alu_op == ALU_SUB)
            else $error("SUB: ALU operation incorrect");

        $display("TEST 2 PASSED: SUB");


        // ========================================================
        // TEST 3
        // AND x5, x6, x7
        // ========================================================

        instr = 32'h007372B3;
        #1;

        assert(is_rtype == 1'b1)
            else $error("AND: R-type not detected");

        assert(alu_op == ALU_AND)
            else $error("AND: ALU operation incorrect");

        $display("TEST 3 PASSED: AND");


        // ========================================================
        // TEST 4
        // ADDI x5, x6, 10
        //
        // Machine code:
        // 0x00A30293
        // ========================================================

        instr = 32'h00A30293;
        #1;

        assert(rs1 == 5'd6)
            else $error("ADDI: rs1 incorrect");

        assert(rd == 5'd5)
            else $error("ADDI: rd incorrect");

        assert(is_itype == 1'b1)
            else $error("ADDI: I-type not detected");

        assert(imm_type == IMM_I)
            else $error("ADDI: immediate type incorrect");

        assert(alu_op == ALU_ADD)
            else $error("ADDI: ALU operation incorrect");

        $display("TEST 4 PASSED: ADDI");


        // ========================================================
        // TEST 5
        // LW x5, 8(x10)
        // ========================================================

        // Encoding of:
        // LW x5, 8(x10)

        instr = 32'h00852283;
        #1;

        assert(rs1 == 5'd10)
            else $error("LW: rs1 incorrect");

        assert(rd == 5'd5)
            else $error("LW: rd incorrect");

        assert(is_load == 1'b1)
            else $error("LW: LOAD not detected");

        assert(imm_type == IMM_I)
            else $error("LW: immediate type incorrect");

        assert(alu_op == ALU_ADD)
            else $error("LW: ALU should calculate address using ADD");

        $display("TEST 5 PASSED: LW");


        // ========================================================
        // TEST 6
        // SW x5, 12(x10)
        // ========================================================

        instr = 32'h00552623;
        #1;

        assert(rs1 == 5'd10)
            else $error("SW: rs1 incorrect");

        assert(rs2 == 5'd5)
            else $error("SW: rs2 incorrect");

        assert(is_store == 1'b1)
            else $error("SW: STORE not detected");

        assert(imm_type == IMM_S)
            else $error("SW: immediate type incorrect");

        assert(alu_op == ALU_ADD)
            else $error("SW: ALU should calculate address using ADD");

        $display("TEST 6 PASSED: SW");


        // ========================================================
        // TEST 7
        // BEQ x5, x6, offset
        //
        // opcode = 1100011
        // funct3 = 000
        // ========================================================

        instr = 32'h00628063;
        #1;

        assert(rs1 == 5'd5)
            else $error("BEQ: rs1 incorrect");

        assert(rs2 == 5'd6)
            else $error("BEQ: rs2 incorrect");

        assert(is_branch == 1'b1)
            else $error("BEQ: BRANCH not detected");

        assert(imm_type == IMM_B)
            else $error("BEQ: immediate type incorrect");

        assert(alu_op == ALU_SUB)
            else $error("BEQ: ALU should perform SUB");

        $display("TEST 7 PASSED: BEQ");


        // ========================================================
        // TEST 8
        // JAL x5, offset
        // ========================================================

        instr = 32'h008000EF;
        #1;

        assert(rd == 5'd1)
            else $error("JAL: rd incorrect");

        assert(is_jal == 1'b1)
            else $error("JAL: JAL not detected");

        assert(imm_type == IMM_J)
            else $error("JAL: immediate type incorrect");

        $display("TEST 8 PASSED: JAL");


        // ========================================================
        // TEST 9
        // JALR x5, 8(x6)
        // ========================================================

        instr = 32'h008302E7;
        #1;

        assert(rs1 == 5'd6)
            else $error("JALR: rs1 incorrect");

        assert(rd == 5'd5)
            else $error("JALR: rd incorrect");

        assert(is_jalr == 1'b1)
            else $error("JALR: JALR not detected");

        assert(imm_type == IMM_I)
            else $error("JALR: immediate type incorrect");

        $display("TEST 9 PASSED: JALR");


        // ========================================================
        // TEST 10
        // LUI x5, immediate
        // ========================================================

        instr = 32'h123452B7;
        #1;

        assert(rd == 5'd5)
            else $error("LUI: rd incorrect");

        assert(is_lui == 1'b1)
            else $error("LUI: LUI not detected");

        assert(imm_type == IMM_U)
            else $error("LUI: immediate type incorrect");

        $display("TEST 10 PASSED: LUI");


        // ========================================================
        // TEST 11
        // AUIPC x5, immediate
        // ========================================================

        instr = 32'h12345297;
        #1;

        assert(rd == 5'd5)
            else $error("AUIPC: rd incorrect");

        assert(is_auipc == 1'b1)
            else $error("AUIPC: AUIPC not detected");

        assert(imm_type == IMM_U)
            else $error("AUIPC: immediate type incorrect");

        $display("TEST 11 PASSED: AUIPC");


        // ========================================================
        // FINISH
        // ========================================================

        $display("");
        $display("======================================");
        $display("ALL DECODER TESTS PASSED");
        $display("======================================");

        $finish;

    end

endmodule
