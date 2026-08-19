module datapath (

    // ============================================================
    // CLOCK AND RESET
    // ============================================================

    input logic clk,
    input logic reset,


    // ============================================================
    // CONTROL SIGNALS FROM FSM
    // ============================================================

    input logic ir_write,
    input logic pc_write,

    input logic a_write,
    input logic b_write,

    input logic aluout_write,
    input logic mdr_write,

    input logic reg_write,


    // ============================================================
    // ALU CONTROL
    // ============================================================

    // 0 = A register
    // 1 = PC
    input logic alu_src_a,

    // 00 = B register
    // 01 = immediate
    // 10 = constant 4
    input logic [1:0] alu_src_b,

    // ALU operation
    input logic [3:0] alu_op,


    // ============================================================
    // MEMORY ADDRESS CONTROL
    // ============================================================

    // 0 = PC
    // 1 = ALUOut
    input logic mem_addr_sel,


    // ============================================================
    // WRITEBACK CONTROL
    // ============================================================

    // 00 = ALUOut
    // 01 = MDR
    // 10 = PC + 4
    // 11 = immediate

    input logic [1:0] wb_sel,


    // ============================================================
    // MEMORY INTERFACE
    // ============================================================

    input logic [31:0] mem_rdata,

    output logic [31:0] mem_addr,
    output logic [31:0] mem_wdata,


    // ============================================================
    // DECODER INFORMATION TO FSM
    // ============================================================

    // These signals tell the FSM what instruction is currently
    // stored in the Instruction Register.

    output logic is_rtype,
    output logic is_itype,
    output logic is_load,
    output logic is_store,
    output logic is_branch,
    output logic is_jal,
    output logic is_jalr,
    output logic is_lui,
    output logic is_auipc,

    // ALU operation identified by decoder
    output logic [3:0] decoder_alu_op,


    // ============================================================
    // DEBUG OUTPUTS
    // ============================================================

    output logic [31:0] instruction,
    output logic [31:0] pc_out,
    output logic [31:0] aluout_out,

    output logic [31:0] a_out,
    output logic [31:0] b_out,

    output logic [31:0] immediate_out,
    output logic [31:0] alu_result_out,

    output logic alu_zero

);


    // ============================================================
    // CPU REGISTERS
    // ============================================================

    logic [31:0] pc;
    logic [31:0] ir;
    logic [31:0] mdr;

    logic [31:0] a_reg;
    logic [31:0] b_reg;

    logic [31:0] aluout;


    // ============================================================
    // DECODER INTERNAL SIGNALS
    // ============================================================

    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] rd;

    logic [2:0] funct3;
    logic [6:0] funct7;

    logic [2:0] decoder_imm_type;


    // ============================================================
    // DECODER
    // ============================================================

    decoder decoder_inst (

        .instr(ir),

        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),

        .funct3(funct3),
        .funct7(funct7),

        .imm_type(decoder_imm_type),
        .alu_op(decoder_alu_op),

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


    // ============================================================
    // IMMEDIATE GENERATOR
    // ============================================================

    logic [31:0] immediate;

    imm_gen imm_gen_inst (

        .instr(ir),

        .imm_type(decoder_imm_type),

        .imm(immediate)

    );


    // ============================================================
    // REGISTER FILE
    // ============================================================

    logic [31:0] rs1_data;
    logic [31:0] rs2_data;

    logic [31:0] wb_data;


    regfile regfile_inst (

        .clk(clk),
        .reset(reset),

        .rs1_addr(rs1),
        .rs2_addr(rs2),

        .rd_addr(rd),

        .rd_data(wb_data),

        .reg_write(reg_write),

        .rs1_data(rs1_data),
        .rs2_data(rs2_data)

    );


    // ============================================================
    // A/B OPERAND REGISTERS
    // ============================================================

    always_ff @(posedge clk) begin

        if (reset) begin

            a_reg <= 32'd0;
            b_reg <= 32'd0;

        end
        else begin

            if (a_write)
                a_reg <= rs1_data;

            if (b_write)
                b_reg <= rs2_data;

        end

    end


    // ============================================================
    // ALU INPUT A
    // ============================================================

    logic [31:0] alu_a;

    always_comb begin

        case (alu_src_a)

            // A register
            1'b0:
                alu_a = a_reg;

            // PC
            1'b1:
                alu_a = pc;

            default:
                alu_a = 32'd0;

        endcase

    end


    // ============================================================
    // ALU INPUT B
    // ============================================================

    logic [31:0] alu_b;

    always_comb begin

        case (alu_src_b)

            // B register
            2'b00:
                alu_b = b_reg;

            // Immediate
            2'b01:
                alu_b = immediate;

            // Constant 4
            2'b10:
                alu_b = 32'd4;

            default:
                alu_b = 32'd0;

        endcase

    end


    // ============================================================
    // ALU
    // ============================================================

    logic [31:0] alu_result;

    alu alu_inst (

        .a(alu_a),
        .b(alu_b),

        .alu_ctrl(alu_op),

        .result(alu_result),

        .zero(alu_zero)

    );


    // ============================================================
    // ALU OUTPUT REGISTER
    // ============================================================

    always_ff @(posedge clk) begin

        if (reset)

            aluout <= 32'd0;

        else if (aluout_write)

            aluout <= alu_result;

    end


    // ============================================================
    // INSTRUCTION REGISTER
    // ============================================================

    always_ff @(posedge clk) begin

        if (reset)

            ir <= 32'd0;

        else if (ir_write)

            ir <= mem_rdata;

    end


    // ============================================================
    // MEMORY DATA REGISTER
    // ============================================================

    always_ff @(posedge clk) begin

        if (reset)

            mdr <= 32'd0;

        else if (mdr_write)

            mdr <= mem_rdata;

    end


    // ============================================================
    // PROGRAM COUNTER
    // ============================================================

    always_ff @(posedge clk) begin

        if (reset)

            pc <= 32'd0;

        else if (pc_write)

            pc <= alu_result;

    end


    // ============================================================
    // WRITEBACK MUX
    // ============================================================

    always_comb begin

        case (wb_sel)

            // ALUOut
            2'b00:
                wb_data = aluout;

            // MDR
            2'b01:
                wb_data = mdr;

            // PC + 4
            2'b10:
                wb_data = pc + 32'd4;

            // Immediate
            2'b11:
                wb_data = immediate;

            default:
                wb_data = 32'd0;

        endcase

    end


    // ============================================================
    // MEMORY ADDRESS MUX
    // ============================================================

    // FETCH:
    //
    // mem_addr = PC
    //
    // LOAD/STORE:
    //
    // mem_addr = ALUOut

    assign mem_addr = (mem_addr_sel == 1'b0)
                    ? pc
                    : aluout;


    // ============================================================
    // MEMORY WRITE DATA
    // ============================================================

    assign mem_wdata = b_reg;


    // ============================================================
    // DEBUG OUTPUTS
    // ============================================================

    assign instruction    = ir;
    assign pc_out         = pc;
    assign aluout_out     = aluout;

    assign a_out          = a_reg;
    assign b_out          = b_reg;

    assign immediate_out  = immediate;
    assign alu_result_out = alu_result;

endmodule
