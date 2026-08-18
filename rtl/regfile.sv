//2 asynchronous read ports (r type instructions like add require two inputs)
//1 synchronous write port
//x0 always reads as 0 (RISC V REQUIREMENT)
//writes to x0 are ignored
//reset clears the other registers


module regfile (
    input  logic        clk,
    input  logic        reset,

    input  logic [4:0]  rs1_addr,
    input  logic [4:0]  rs2_addr,
    input  logic [4:0]  rd_addr,
    input  logic [31:0] rd_data,
    input  logic        reg_write,

    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data
);

    logic [31:0] regs [0:31];

    integer i;

    always_ff @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                regs[i] <= 32'd0;
            end
        end
        else if (reg_write && (rd_addr != 5'd0)) begin
            regs[rd_addr] <= rd_data;
        end
    end

    always_comb begin
        if (rs1_addr == 5'd0)
            rs1_data = 32'd0;
        else
            rs1_data = regs[rs1_addr];

        if (rs2_addr == 5'd0)
            rs2_data = 32'd0;
        else
            rs2_data = regs[rs2_addr];
    end

endmodule
