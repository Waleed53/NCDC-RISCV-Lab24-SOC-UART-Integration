module control_unit (
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    output logic       regWriteEn,
    output logic       aluSrc,
    output logic [1:0] aluOp,
    output logic       memRead,
    output logic       memWrite,
    output logic       memToReg,
    output logic [2:0] memCtrl,
    output logic jalTaken
    
);

    always_comb begin
        regWriteEn = 1'b0;
        aluSrc = 1'b0;
        aluOp = 2'b00;
        memRead = 1'b0;
        memWrite = 1'b0;
        memToReg = 1'b0;
        memCtrl = 3'b000;
        
        case (opcode)
            7'b0110011: begin // R-type
                regWriteEn = 1'b1;
                aluSrc = 1'b0;     
                aluOp = 2'b10;     
                memRead = 1'b0;
                memWrite = 1'b0;
                memToReg = 1'b0;
                jalTaken   = 1'b0; 
            end
            7'b0010011: begin // I-type (arithmetic)
                regWriteEn = 1'b1;
                aluSrc = 1'b1;     
                aluOp = 2'b00;     
                memRead = 1'b0;
                memWrite = 1'b0;
                memToReg = 1'b0;
                jalTaken   = 1'b0; 
            end
            7'b0000011: begin // Load instructions (I-type)
                regWriteEn = 1'b1;
                aluSrc = 1'b1;      // Use immediate for address calculation
                aluOp = 2'b11;      // FIXED: Use dedicated load/store ALU operation
                memRead = 1'b1;     
                memWrite = 1'b0;    
                memToReg = 1'b1;    
                memCtrl = funct3;  
                jalTaken   = 1'b0;  
            end
            7'b0100011: begin // Store instructions (S-type)
                regWriteEn = 1'b0;  
                aluSrc = 1'b1;      // Use immediate for address calculation
                aluOp = 2'b11;      // FIXED: Use dedicated load/store ALU operation
                memRead = 1'b0;     
                memWrite = 1'b1;    
                memToReg = 1'b0;    
                memCtrl = funct3;   
                jalTaken   = 1'b0; 
            end
            7'b1101111: begin // JAL
                regWriteEn = 1'b1;       // store return address in rd
                aluSrc     = 1'b0;       // ALU not used
                memRead    = 1'b0;
                memWrite   = 1'b0;
                memToReg   = 1'b0;       // rd = PC+4
                jalTaken   = 1'b1;       // PC will jump
            end
            7'b1100111: begin // JALR
                regWriteEn = 1'b1;    // store return address in rd
                memRead    = 1'b0;
                memWrite   = 1'b0;
                memToReg   = 1'b0;    // rd = PC+4
                aluSrc     = 1'b0;    // ALU not used for target
                jalTaken   = 1'b0;
            end
            7'b1100011: begin // Branch instructions
                regWriteEn = 1'b0;  // branches do not write registers
                aluSrc     = 1'b0;  // ALU compares registers
                memRead    = 1'b0;
                memWrite   = 1'b0;
                memToReg   = 1'b0;
                jalTaken   = 1'b0;
            end
            7'b0110111: begin // LUI
                regWriteEn = 1'b1;
                aluSrc     = 1'b1;   // use immediate
                aluOp      = 2'b11;  // pass immediate or use ADD in ALU
                memRead    = 1'b0;
                memWrite   = 1'b0;
                memToReg   = 1'b0;   // write ALU result
            end
            7'b0010111: begin // AUIPC
                regWriteEn = 1'b1;
                aluSrc     = 1'b1;   // use PC + immediate
                aluOp      = 2'b11;  // ALU performs PC + imm
                memRead    = 1'b0;
                memWrite   = 1'b0;
                memToReg   = 1'b0;   // write ALU result
            end

            default: begin
                regWriteEn = 1'b0;
                aluSrc = 1'b0;
                aluOp = 2'b00;
                memRead = 1'b0;
                memWrite = 1'b0;
                memToReg = 1'b0;
                memCtrl = 3'b000;
                jalTaken   = 1'b0; 
            end
        endcase
    end
always @(*) begin
  $display("RegWriteEn=%d", regWriteEn);
end
endmodule