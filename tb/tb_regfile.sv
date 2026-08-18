module tb_regfile;

    logic        clk;
    logic        reset;

    logic [4:0]  rs1_addr;
    logic [4:0]  rs2_addr;
    logic [4:0]  rd_addr;
    logic [31:0] rd_data;
    logic        reg_write;

    logic [31:0] rs1_data;
    logic [31:0] rs2_data;


    regfile dut (
        .clk(clk),
        .reset(reset),

        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .rd_data(rd_data),
        .reg_write(reg_write),

        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );


    // Generate 10 ns clock
    initial begin
        clk = 0;

        forever #5 clk = ~clk;
    end


    initial begin

        // Initial values
        reset    = 1;
        reg_write = 0;
        rs1_addr = 0;
        rs2_addr = 0;
        rd_addr  = 0;
        rd_data  = 0;


        // -------------------------
        // TEST 1: RESET
        // -------------------------

        #12;

        reset = 0;

        #1;

        assert(rs1_data == 32'd0)
            else $error("TEST 1 FAILED: x0 is not zero");

        $display("TEST 1 PASSED: Reset");


        // -------------------------
        // TEST 2: WRITE x5 = 123
        // -------------------------

        rd_addr   = 5;
        rd_data   = 123;
        reg_write = 1;

        #10;

        reg_write = 0;

        rs1_addr = 5;

        #1;

        assert(rs1_data == 32'd123)
            else $error("TEST 2 FAILED: x5 != 123");

        $display("TEST 2 PASSED: Write/read x5");


        // -------------------------
        // TEST 3: WRITE x10 = 456
        // -------------------------

        rd_addr   = 10;
        rd_data   = 456;
        reg_write = 1;

        #10;

        reg_write = 0;

        rs1_addr = 10;

        #1;

        assert(rs1_data == 32'd456)
            else $error("TEST 3 FAILED: x10 != 456");

        $display("TEST 3 PASSED: Write/read x10");


        // -------------------------
        // TEST 4: x0 MUST ALWAYS BE 0
        // -------------------------

        rs1_addr = 0;

        #1;

        assert(rs1_data == 32'd0)
            else $error("TEST 4 FAILED: x0 is not zero");

        $display("TEST 4 PASSED: x0 reads zero");


        // -------------------------
        // TEST 5: TRY TO WRITE x0
        // -------------------------

        rd_addr   = 0;
        rd_data   = 999;
        reg_write = 1;

        #10;

        reg_write = 0;

        rs1_addr = 0;

        #1;

        assert(rs1_data == 32'd0)
            else $error("TEST 5 FAILED: x0 was modified");

        $display("TEST 5 PASSED: x0 write ignored");


        // -------------------------
        // TEST 6: TWO READ PORTS
        // -------------------------

        rs1_addr = 5;
        rs2_addr = 10;

        #1;

        assert(rs1_data == 32'd123)
            else $error("TEST 6 FAILED: rs1 incorrect");

        assert(rs2_data == 32'd456)
            else $error("TEST 6 FAILED: rs2 incorrect");

        $display("TEST 6 PASSED: Two read ports");


        // -------------------------
        // FINISH
        // -------------------------

        $display("================================");
        $display("ALL REGISTER FILE TESTS PASSED");
        $display("================================");

        $finish;

    end

endmodule
