module regFile (
    input  logic        clk,
    input  logic        reset,
    input  logic [4:0]  rs1,
    input  logic [4:0]  rs2,
    input  logic [4:0]  rd,
    input  logic [31:0] writeData,
    input  logic        regWriteEn,
    output logic [31:0] readData1,
    output logic [31:0] readData2
);

    logic [31:0] regs [0:31];
    integer i;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i++) regs[i] <= 32'd0;
        end else if (regWriteEn && rd != 5'd0) begin
            regs[rd] <= writeData;
        end
    end

    assign readData1 = regs[rs1];
    assign readData2 = regs[rs2];

endmodule