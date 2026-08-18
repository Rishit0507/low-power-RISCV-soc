module tb_imm_gen;

    logic [31:0] instr;
    logic [31:0] imm;

    imm_gen dut (
        .instr(instr),
        .imm(imm)
    );

    initial begin

        // ADDI x5, x6, 10
        instr = 32'h00A30293;
        #1;

        assert(imm == 32'd10)
            else $error("ADDI immediate failed: got %h", imm);

        $display("ADDI immediate = %0d", imm);


        // ADDI x5, x6, -1
        instr = 32'hFFF30293;
        #1;

        assert(imm == 32'hFFFFFFFF)
            else $error("Negative I-immediate failed: got %h", imm);

        $display("Negative I-immediate = %h", imm);


        // SW x5, 12(x10)
        instr = 32'h00552623;
        #1;

        assert(imm == 32'd12)
            else $error("SW immediate failed: got %h", imm);

        $display("SW immediate = %0d", imm);


        $display("==============================");
        $display("IMM_GEN TESTS PASSED");
        $display("==============================");

        $finish;

    end

endmodule
