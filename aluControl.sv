module alu_control (
    input  logic [1:0] aluOp,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    output logic [3:0] aluCtrl
);

    always_comb begin
        case (aluOp)
            2'b00: begin // I-type arithmetic operations
                case (funct3)
                    3'b000: aluCtrl = 4'b0010; // addi
                    3'b111: aluCtrl = 4'b0000; // andi
                    3'b110: aluCtrl = 4'b0001; // ori
                    3'b100: aluCtrl = 4'b0100; // xori
                    3'b001: aluCtrl = 4'b0101; // slli
                    3'b101: begin
                        if (funct7 == 7'b0100000)
                            aluCtrl = 4'b0111; // srai
                        else
                            aluCtrl = 4'b0110; // srli
                    end
                    default: aluCtrl = 4'b0010; // Default to ADD
                endcase
            end
            2'b01: begin // beq
                aluCtrl = 4'b1000; // subtract for comparison
            end
            2'b10: begin // R-type instructions
                case ({funct7, funct3})
                    {7'b0000000, 3'b000}: aluCtrl = 4'b0010; // ADD
                    {7'b0100000, 3'b000}: aluCtrl = 4'b1000; // SUB
                    {7'b0000000, 3'b111}: aluCtrl = 4'b0000; // AND
                    {7'b0000000, 3'b110}: aluCtrl = 4'b0001; // OR
                    {7'b0000000, 3'b100}: aluCtrl = 4'b0100; // XOR
                    {7'b0000000, 3'b001}: aluCtrl = 4'b0101; // SLL
                    {7'b0000000, 3'b101}: aluCtrl = 4'b0110; // SRL
                    {7'b0100000, 3'b101}: aluCtrl = 4'b0111; // SRA
                    {7'b0000000, 3'b010}: aluCtrl = 4'b1001; // SLT
                    default: aluCtrl = 4'b0010; 
                endcase
            end
            2'b11: begin // FIXED: Load/Store operations - always ADD for address calculation
                aluCtrl = 4'b0010; 
            end
            default: aluCtrl = 4'b0010; 
        endcase
    end
    always @(*) begin
    $display("aluOp=%b funct7=%b funct3=%b aluCtrl=%b",
             aluOp, funct7, funct3, aluCtrl);
end

endmodule