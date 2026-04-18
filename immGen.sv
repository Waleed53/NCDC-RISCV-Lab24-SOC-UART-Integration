module immGen (
    input  logic [31:0] inst,
    output logic [31:0] imm
);

    logic [6:0] opcode = inst[6:0];
    
    always_comb begin
        logic [6:0] opcode;
        opcode  = inst[6:0];
        case (opcode)
            7'b0010011: begin // I-type (arithmetic immediate)
                if (inst[14:12] == 3'b001 || inst[14:12] == 3'b101) begin
                    // For shift instructions (slli, srli, srai), only use lower 5 bits
                    imm = {27'b0, inst[24:20]};
                end else begin
                    // Regular I-type immediate (sign extended)
                    imm = {{20{inst[31]}}, inst[31:20]};
                end
            end
            7'b0000011: begin // Load instructions (I-type)
                imm = {{20{inst[31]}}, inst[31:20]};
            end
            7'b1100111: begin // JALR
                imm = {{20{inst[31]}}, inst[31:20]};
            end
            7'b0100011: begin // Store instructions
                imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};
            end
            7'b1101111: begin // JAL
                imm = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
            end
            7'b1100011: begin // B-type branch
                imm = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
            end
            7'b0110111: imm = {inst[31:12], 12'b0}; // LUI and AUIPC
             7'b0010111: imm = {inst[31:12], 12'b0}; // AUIPC
            default: begin
                imm = 32'b0;
            end
        endcase
    end

endmodule