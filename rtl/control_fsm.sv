module control_fsm (

    // ============================================================
    // CLOCK AND RESET
    // ============================================================

    input logic clk,
    input logic reset,


    // ============================================================
    // DECODER INFORMATION
    // ============================================================

    input logic is_rtype,
    input logic is_itype,
    input logic is_load,
    input logic is_store,
    input logic is_branch,
    input logic is_jal,
    input logic is_jalr,
    input logic is_lui,
    input logic is_auipc,

    // ALU operation determined by decoder
    input logic [3:0] decoder_alu_op,


    // ============================================================
    // CONTROL OUTPUTS
    // ============================================================

    output logic ir_write,
    output logic pc_write,

    output logic a_write,
    output logic b_write,

    output logic aluout_write,
    output logic mdr_write,

    output logic reg_write,

    output logic alu_src_a,
    output logic [1:0] alu_src_b,

    output logic [3:0] alu_op,

    output logic [1:0] wb_sel,

    output logic mem_addr_sel,

    output logic mem_read,
    output logic mem_write,


    // ============================================================
    // DEBUG STATE
    // ============================================================

    output logic [3:0] state

);


    // ============================================================
    // FSM STATES
    // ============================================================

    localparam FETCH      = 4'd0;
    localparam DECODE     = 4'd1;

    localparam EXEC_R     = 4'd2;
    localparam EXEC_I     = 4'd3;

    localparam MEM_ADDR   = 4'd4;
    localparam MEM_READ   = 4'd5;
    localparam MEM_WB     = 4'd6;
    localparam MEM_WRITE  = 4'd7;

    localparam BRANCH     = 4'd8;
    localparam JAL        = 4'd9;
    localparam JALR       = 4'd10;
    localparam LUI        = 4'd11;
    localparam AUIPC      = 4'd12;

    // NEW:
    // ALU_WB writes ALUOut into rd.
    localparam ALU_WB     = 4'd13;


    logic [3:0] next_state;


    // ============================================================
    // STATE REGISTER
    // ============================================================

    always_ff @(posedge clk) begin

        if (reset)

            state <= FETCH;

        else

            state <= next_state;

    end


    // ============================================================
    // NEXT STATE LOGIC
    // ============================================================

    always_comb begin

        // Default: remain in current state.
        next_state = state;


        case (state)

            // ----------------------------------------------------
            // FETCH
            // ----------------------------------------------------

            FETCH: begin

                next_state = DECODE;

            end


            // ----------------------------------------------------
            // DECODE
            // ----------------------------------------------------

            DECODE: begin

                if (is_rtype)

                    next_state = EXEC_R;

                else if (is_load || is_store)

                    next_state = MEM_ADDR;

                else if (is_itype)

                    next_state = EXEC_I;

                else if (is_branch)

                    next_state = BRANCH;

                else if (is_jal)

                    next_state = JAL;

                else if (is_jalr)

                    next_state = JALR;

                else if (is_lui)

                    next_state = LUI;

                else if (is_auipc)

                    next_state = AUIPC;

                else

                    next_state = FETCH;

            end


            // ----------------------------------------------------
            // R-TYPE EXECUTION
            // ----------------------------------------------------

            EXEC_R: begin

                // ALU result is captured in ALUOut.
                next_state = ALU_WB;

            end


            // ----------------------------------------------------
            // I-TYPE EXECUTION
            // ----------------------------------------------------

            EXEC_I: begin

                // ALU result is captured in ALUOut.
                next_state = ALU_WB;

            end


            // ----------------------------------------------------
            // ALU WRITEBACK
            // ----------------------------------------------------

            ALU_WB: begin

                // Write ALUOut into rd.
                next_state = FETCH;

            end


            // ----------------------------------------------------
            // MEMORY ADDRESS
            // ----------------------------------------------------

            MEM_ADDR: begin

                if (is_load)

                    next_state = MEM_READ;

                else

                    next_state = MEM_WRITE;

            end


            // ----------------------------------------------------
            // MEMORY READ
            // ----------------------------------------------------

            MEM_READ:

                next_state = MEM_WB;


            // ----------------------------------------------------
            // MEMORY WRITEBACK
            // ----------------------------------------------------

            MEM_WB:

                next_state = FETCH;


            // ----------------------------------------------------
            // MEMORY WRITE
            // ----------------------------------------------------

            MEM_WRITE:

                next_state = FETCH;


            // ----------------------------------------------------
            // BRANCH
            // ----------------------------------------------------

            BRANCH:

                next_state = FETCH;


            // ----------------------------------------------------
            // JAL
            // ----------------------------------------------------

            JAL:

                next_state = FETCH;


            // ----------------------------------------------------
            // JALR
            // ----------------------------------------------------

            JALR:

                next_state = FETCH;


            // ----------------------------------------------------
            // LUI
            // ----------------------------------------------------

            LUI:

                next_state = FETCH;


            // ----------------------------------------------------
            // AUIPC
            // ----------------------------------------------------

            AUIPC:

                next_state = ALU_WB;


            // ----------------------------------------------------
            // SAFETY
            // ----------------------------------------------------

            default:

                next_state = FETCH;

        endcase

    end


    // ============================================================
    // OUTPUT CONTROL LOGIC
    // ============================================================

    always_comb begin

        // --------------------------------------------------------
        // SAFE DEFAULTS
        // --------------------------------------------------------

        ir_write     = 1'b0;
        pc_write     = 1'b0;

        a_write      = 1'b0;
        b_write      = 1'b0;

        aluout_write = 1'b0;
        mdr_write    = 1'b0;

        reg_write    = 1'b0;

        alu_src_a    = 1'b0;
        alu_src_b    = 2'b00;

        alu_op       = decoder_alu_op;

        wb_sel       = 2'b00;

        mem_addr_sel = 1'b0;

        mem_read     = 1'b0;
        mem_write    = 1'b0;


        case (state)

            // ====================================================
            // FETCH
            // ====================================================

            FETCH: begin

                // Memory address = PC.
                mem_addr_sel = 1'b0;

                // Read instruction.
                mem_read = 1'b1;

                // Capture instruction.
                ir_write = 1'b1;


                // PC + 4
                alu_src_a = 1'b1;
                alu_src_b = 2'b10;

                pc_write = 1'b1;

            end


            // ====================================================
            // DECODE
            // ====================================================

            DECODE: begin

                // Capture rs1 and rs2.

                a_write = 1'b1;
                b_write = 1'b1;

            end


            // ====================================================
            // R-TYPE EXECUTION
            // ====================================================

            EXEC_R: begin

                // A + B / A - B / AND / OR / XOR etc.

                alu_src_a = 1'b0;
                alu_src_b = 2'b00;

                alu_op = decoder_alu_op;

                // Save result.
                aluout_write = 1'b1;

            end


            // ====================================================
            // I-TYPE EXECUTION
            // ====================================================

            EXEC_I: begin

                // rs1 + immediate

                alu_src_a = 1'b0;
                alu_src_b = 2'b01;

                alu_op = decoder_alu_op;

                // Save result.
                aluout_write = 1'b1;

            end


            // ====================================================
            // ALU WRITEBACK
            // ====================================================

            ALU_WB: begin

                // ALUOut is the value written to rd.

                wb_sel = 2'b00;

                reg_write = 1'b1;

            end


            // ====================================================
            // MEMORY ADDRESS CALCULATION
            // ====================================================

            MEM_ADDR: begin

                // Effective address:
                //
                // rs1 + immediate

                alu_src_a = 1'b0;
                alu_src_b = 2'b01;

                // Address calculation always uses ADD.
                alu_op = 4'b0000;

                aluout_write = 1'b1;

            end


            // ====================================================
            // MEMORY READ
            // ====================================================

            MEM_READ: begin

                // Memory address = ALUOut.
                mem_addr_sel = 1'b1;

                mem_read = 1'b1;

                // Capture memory response.
                mdr_write = 1'b1;

            end


            // ====================================================
            // MEMORY WRITEBACK
            // ====================================================

            MEM_WB: begin

                // MDR ? rd

                wb_sel = 2'b01;

                reg_write = 1'b1;

            end


            // ====================================================
            // MEMORY WRITE
            // ====================================================

            MEM_WRITE: begin

                // Memory address = ALUOut.
                mem_addr_sel = 1'b1;

                // B register ? memory.
                mem_write = 1'b1;

            end


            // ====================================================
            // BRANCH
            // ====================================================

            BRANCH: begin

                // Branch implementation comes later.

            end


            // ====================================================
            // JAL
            // ====================================================

            JAL: begin

                // Jump implementation comes later.

            end


            // ====================================================
            // JALR
            // ====================================================

            JALR: begin

                // JALR implementation comes later.

            end


            // ====================================================
            // LUI
            // ====================================================

            LUI: begin

                wb_sel = 2'b11;

                reg_write = 1'b1;

            end


            // ====================================================
            // AUIPC
            // ====================================================

            AUIPC: begin

                // PC + immediate

                alu_src_a = 1'b1;
                alu_src_b = 2'b01;

                alu_op = 4'b0000;

                aluout_write = 1'b1;

            end

        endcase

    end

endmodule
