//This converts the immediate field encoded inside an RV32I instruction into a signed 32-bit value.
//I-type → ADDI, LW, etc.
//S-type → SW, SH, SB
//B-type → BEQ, BNE, etc.
//U-type → LUI, AUIPC
//J-type → JAL

module imm_gen (

    // Complete 32-bit instruction
    input logic [31:0] instr,

    // Immediate format selected by the decoder
    input logic [2:0] imm_type,

    // Generated 32-bit immediate
    output logic [31:0] imm

);

    // Immediate type definitions.
    // These MUST match decoder.sv.

    localparam IMM_NONE = 3'b000;
    localparam IMM_I    = 3'b001;
    localparam IMM_S    = 3'b010;
    localparam IMM_B    = 3'b011;
    localparam IMM_U    = 3'b100;
    localparam IMM_J    = 3'b101;


    always_comb begin

        case (imm_type)

            // ----------------------------------------------------
            // I-type
            //
            // Bits:
            // [31:20]
            //
            // Sign extend 12-bit immediate to 32 bits.
            // ----------------------------------------------------

            IMM_I: begin

                imm = {{20{instr[31]}},
                       instr[31:20]};

            end


            // ----------------------------------------------------
            // S-type
            //
            // Used by SW.
            //
            // Immediate is split between:
            // [31:25] and [11:7]
            // ----------------------------------------------------

            IMM_S: begin

                imm = {{20{instr[31]}},
                       instr[31:25],
                       instr[11:7]};

            end


            // ----------------------------------------------------
            // B-type
            //
            // Used by BEQ/BNE.
            //
            // The immediate is scattered across the instruction.
            // The lowest bit is always 0 because branch targets
            // are aligned to 2-byte boundaries.
            // ----------------------------------------------------

            IMM_B: begin

                imm = {{19{instr[31]}},
                       instr[31],
                       instr[7],
                       instr[30:25],
                       instr[11:8],
                       1'b0};

            end


            // ----------------------------------------------------
            // U-type
            //
            // Used by LUI/AUIPC.
            //
            // Lower 12 bits are zero.
            // ----------------------------------------------------

            IMM_U: begin

                imm = {instr[31:12],
                       12'b0};

            end


            // ----------------------------------------------------
            // J-type
            //
            // Used by JAL.
            //
            // Immediate bits are scattered across the instruction.
            // Lowest bit is always 0.
            // ----------------------------------------------------

            IMM_J: begin

                imm = {{11{instr[31]}},
                       instr[31],
                       instr[19:12],
                       instr[20],
                       instr[30:21],
                       1'b0};

            end


            // ----------------------------------------------------
            // No immediate
            // ----------------------------------------------------

            default: begin

                imm = 32'b0;

            end

        endcase

    end

endmodule
