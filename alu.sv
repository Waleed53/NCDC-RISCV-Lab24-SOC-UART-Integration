// UNCHANGED: ALU module remains the same
module alu (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [3:0]  aluCtrl,
    output logic [31:0] aluResult,
    output logic        zero,
    output logic lt,  // signed less than
    output logic ltu  // unsigned less than
);

    always_comb begin
    lt  = ($signed(a) < $signed(b));   // signed comparison
    ltu = (a < b);
        case (aluCtrl)
            4'b0000: aluResult = a & b;        // AND
            4'b0001: aluResult = a | b;        // OR
            4'b0010: aluResult = a + b;        // ADD
            4'b0100: aluResult = a ^ b;        // XOR
            4'b0101: aluResult = a << b[4:0];  // SLL 
            4'b0110: aluResult = a >> b[4:0];  // SRL 
            4'b0111: aluResult = $signed(a) >>> b[4:0]; // SRA
            4'b1000: aluResult = a - b;        // SUB
            4'b1001: aluResult = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; // SLT
            default: aluResult = 32'h0;
        endcase
    end


    assign zero = (aluResult == 32'd0);

endmodule