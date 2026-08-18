module tb_alu;

    logic [31:0] a;
    logic [31:0] b;
    logic [3:0]  alu_ctrl;
    logic [31:0] result;
    logic        zero;

    alu dut (
        .a(a),
        .b(b),
        .alu_ctrl(alu_ctrl),
        .result(result),
        .zero(zero)
    );

    initial begin

        a = 32'd10;
        b = 32'd20;
        alu_ctrl = 4'b0000;
        #10;

        assert(result == 32'd30)
            else $error("ADD failed");

        a = 32'd20;
        b = 32'd10;
        alu_ctrl = 4'b0001;
        #10;

        assert(result == 32'd10)
            else $error("SUB failed");

        a = 32'hF0F0F0F0;
        b = 32'h0F0F0F0F;
        alu_ctrl = 4'b0010;
        #10;

        assert(result == 32'd0)
            else $error("AND failed");

        assert(zero == 1'b1)
            else $error("ZERO flag failed");

        $display("ALU tests passed");

        $finish;

    end

endmodule
