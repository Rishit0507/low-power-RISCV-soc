module decoder (

    // Complete 32-bit RISC-V instruction
    input  logic [31:0] instr,

    // Register addresses extracted from the instruction
    output logic [4:0]  rs1,
    output logic [4:0]  rs2,
    output logic [4:0]  rd,

    // Instruction fields
    output logic [2:0]  funct3,
    output logic [6:0]  funct7,

    // Immediate format required by the immediate generator
    output logic [2:0]  imm_type,

    // Operation that the ALU must perform
    output logic [3:0]  alu_op,

    // Instruction classification
    output logic        is_rtype,
    output logic        is_itype,
    output logic        is_load,
    output logic        is_store,
    output logic        is_branch,
    output logic        is_jal,
    output logic        is_jalr,
    output logic        is_lui,
    output logic        is_auipc

);

    // ------------------------------------------------------------
    // RISC-V opcode definitions
    // ------------------------------------------------------------

    localparam [6:0] OPCODE_RTYPE  = 7'b0110011; // Register operations
    localparam [6:0] OPCODE_ITYPE  = 7'b0010011; // Immediate ALU operations
    localparam [6:0] OPCODE_LOAD   = 7'b0000011; // Loads
    localparam [6:0] OPCODE_STORE  = 7'b0100011; // Stores
    localparam [6:0] OPCODE_BRANCH = 7'b1100011; // Conditional branches
    localparam [6:0] OPCODE_JAL    = 7'b1101111; // JAL
    localparam [6:0] OPCODE_JALR   = 7'b1100111; // JALR
    localparam [6:0] OPCODE_LUI    = 7'b0110111; // LUI
    localparam [6:0] OPCODE_AUIPC  = 7'b0010111; // AUIPC


    // ------------------------------------------------------------
    // ALU operation definitions
    // These must match the ALU we already implemented.
    // ------------------------------------------------------------

    localparam [3:0] ALU_ADD  = 4'b0000;
    localparam [3:0] ALU_SUB  = 4'b0001;
    localparam [3:0] ALU_AND  = 4'b0010;
    localparam [3:0] ALU_OR   = 4'b0011;
    localparam [3:0] ALU_XOR  = 4'b0100;
    localparam [3:0] ALU_SLL  = 4'b0101;
    localparam [3:0] ALU_SRL  = 4'b0110;
    localparam [3:0] ALU_SRA  = 4'b0111;
    localparam [3:0] ALU_SLT  = 4'b1000;
    localparam [3:0] ALU_SLTU = 4'b1001;


    // ------------------------------------------------------------
    // Immediate type definitions
    // ------------------------------------------------------------

    localparam [2:0] IMM_NONE = 3'b000;
    localparam [2:0] IMM_I    = 3'b001;
    localparam [2:0] IMM_S    = 3'b010;
    localparam [2:0] IMM_B    = 3'b011;
    localparam [2:0] IMM_U    = 3'b100;
    localparam [2:0] IMM_J    = 3'b101;


    // ------------------------------------------------------------
    // Extract fields directly from the instruction.
    // These positions are fixed by the RISC-V ISA.
    // ------------------------------------------------------------

    assign rs1   = instr[19:15];

    assign rs2   = instr[24:20];

    assign rd    = instr[11:7];

    assign funct3 = instr[14:12];

    assign funct7 = instr[31:25];


    // ------------------------------------------------------------
    // Main decoder
    // ------------------------------------------------------------

    always_comb begin

        // --------------------------------------------------------
        // Default values
        // --------------------------------------------------------

        is_rtype  = 1'b0;
        is_itype  = 1'b0;
        is_load   = 1'b0;
        is_store  = 1'b0;
        is_branch = 1'b0;
        is_jal    = 1'b0;
        is_jalr   = 1'b0;
        is_lui    = 1'b0;
        is_auipc  = 1'b0;

        imm_type = IMM_NONE;

        // Default ALU operation
        alu_op = ALU_ADD;


        // --------------------------------------------------------
        // Decode based on opcode
        // --------------------------------------------------------

        case (instr[6:0])


            // ====================================================
            // R-TYPE
            //
            // Example:
            //
            // ADD x5, x6, x7
            //
            // opcode = 0110011
            // ====================================================

            OPCODE_RTYPE: begin

                is_rtype = 1'b1;

                // Determine ALU operation using funct3/funct7

                case (funct3)

                    3'b000: begin

                        // funct7 = 0000000 ? ADD
                        // funct7 = 0100000 ? SUB

                        if (funct7 == 7'b0100000)
                            alu_op = ALU_SUB;
                        else
                            alu_op = ALU_ADD;

                    end

                    3'b111: begin
                        alu_op = ALU_AND;
                    end

                    3'b110: begin
                        alu_op = ALU_OR;
                    end

                    3'b100: begin
                        alu_op = ALU_XOR;
                    end

                    3'b010: begin
                        alu_op = ALU_SLT;
                    end

                    3'b011: begin
                        alu_op = ALU_SLTU;
                    end

                    3'b001: begin
                        alu_op = ALU_SLL;
                    end

                    3'b101: begin

                        // funct7 distinguishes SRL from SRA

                        if (funct7 == 7'b0100000)
                            alu_op = ALU_SRA;
                        else
                            alu_op = ALU_SRL;

                    end

                    default: begin
                        alu_op = ALU_ADD;
                    end

                endcase

            end


            // ====================================================
            // I-TYPE ALU
            //
            // Examples:
            // ADDI
            // ANDI
            // ORI
            // XORI
            // SLTI
            // SLTIU
            // SLLI
            // SRLI
            // SRAI
            // ====================================================

            OPCODE_ITYPE: begin

                is_itype = 1'b1;

                imm_type = IMM_I;

                case (funct3)

                    3'b000: begin
                        alu_op = ALU_ADD;     // ADDI
                    end

                    3'b111: begin
                        alu_op = ALU_AND;     // ANDI
                    end

                    3'b110: begin
                        alu_op = ALU_OR;      // ORI
                    end

                    3'b100: begin
                        alu_op = ALU_XOR;     // XORI
                    end

                    3'b010: begin
                        alu_op = ALU_SLT;     // SLTI
                    end

                    3'b011: begin
                        alu_op = ALU_SLTU;    // SLTIU
                    end

                    3'b001: begin
                        alu_op = ALU_SLL;     // SLLI
                    end

                    3'b101: begin

                        // SRLI and SRAI are distinguished by funct7

                        if (funct7 == 7'b0100000)
                            alu_op = ALU_SRA;
                        else
                            alu_op = ALU_SRL;

                    end

                    default: begin
                        alu_op = ALU_ADD;
                    end

                endcase

            end


            // ====================================================
            // LOAD
            //
            // Initially we only implement LW.
            //
            // LW rd, offset(rs1)
            // ====================================================

            OPCODE_LOAD: begin

                is_load = 1'b1;

                imm_type = IMM_I;

                // Address calculation:
                //
                // address = rs1 + immediate
                //
                alu_op = ALU_ADD;

            end


            // ====================================================
            // STORE
            //
            // Initially we implement SW.
            //
            // SW rs2, offset(rs1)
            // ====================================================

            OPCODE_STORE: begin

                is_store = 1'b1;

                imm_type = IMM_S;

                // Address calculation:
                //
                // address = rs1 + immediate
                //
                alu_op = ALU_ADD;

            end


            // ====================================================
            // BRANCH
            //
            // Initially:
            // BEQ
            // BNE
            // ====================================================

            OPCODE_BRANCH: begin

                is_branch = 1'b1;

                imm_type = IMM_B;

                // Branch comparison will use subtraction.
                //
                // rs1 - rs2 = 0
                //
                // means BEQ condition is true.

                alu_op = ALU_SUB;

            end


            // ====================================================
            // JAL
            //
            // JAL rd, offset
            // ====================================================

            OPCODE_JAL: begin

                is_jal = 1'b1;

                imm_type = IMM_J;

                // JAL needs PC + 4 for rd.
                // The control FSM will handle that separately.

                alu_op = ALU_ADD;

            end


            // ====================================================
            // JALR
            //
            // JALR rd, offset(rs1)
            // ====================================================

            OPCODE_JALR: begin

                is_jalr = 1'b1;

                imm_type = IMM_I;

                // Target address:
                //
                // rs1 + immediate

                alu_op = ALU_ADD;

            end


            // ====================================================
            // LUI
            //
            // LUI rd, immediate
            // ====================================================

            OPCODE_LUI: begin

                is_lui = 1'b1;

                imm_type = IMM_U;

                // LUI simply writes the immediate to rd.

                alu_op = ALU_ADD;

            end


            // ====================================================
            // AUIPC
            //
            // AUIPC rd, immediate
            // ====================================================

            OPCODE_AUIPC: begin

                is_auipc = 1'b1;

                imm_type = IMM_U;

                // AUIPC:
                //
                // rd = PC + immediate
                //
                // Control FSM will select PC as ALU input.

                alu_op = ALU_ADD;

            end


            // ====================================================
            // UNKNOWN OPCODE
            // ====================================================

            default: begin

                // Keep all outputs at their safe defaults.

                is_rtype  = 1'b0;
                is_itype  = 1'b0;
                is_load   = 1'b0;
                is_store  = 1'b0;
                is_branch = 1'b0;
                is_jal    = 1'b0;
                is_jalr   = 1'b0;
                is_lui    = 1'b0;
                is_auipc  = 1'b0;

                imm_type = IMM_NONE;

                alu_op = ALU_ADD;

            end

        endcase

    end

endmodule
