module top (
    input  logic        clk,
    input  logic        reset,
    output logic [31:0] pcOut,
    output logic [31:0] instOut,
    output logic [31:0] aluOut,
    output logic        regWriteEn,
    output logic [31:0] regWriteData,
    output logic [4:0]  rdout,

    output logic        mem_cs,
    output logic        mem_we,       // 1 => write, 0 => read
    output logic [31:0] mem_addr,     // byte address
    output logic [31:0] mem_wdata,    // data to write on writes
    input  logic [31:0] mem_rdata      // read data (returned during read)
);

    logic [31:0] pcNext, pcPlus4;
    logic [31:0] inst;
    logic [31:0] readData1, readData2;
    logic [31:0] imm;

    logic [31:0] aluResult;
    logic        zero;
    logic [3:0]  aluCtrl;
    logic [31:0] aluB;
    logic        aluSrc;
    logic [1:0]  aluOp;
    logic        memRead;
    logic        memWrite;
    logic        memToReg;
    logic [2:0]  memCtrl;
    logic [31:0] memReadData;  // formerly connected to dataMem
    logic [31:0] aluA;
    logic jalTaken;
    logic lt, ltu;

    wire [6:0] opcode = inst[6:0];
    wire [4:0] rd     = inst[11:7];
    wire [2:0] funct3 = inst[14:12];
    wire [4:0] rs1    = inst[19:15];
    wire [4:0] rs2    = inst[24:20];
    wire [6:0] funct7 = inst[31:25];

    assign aluA = (opcode == 7'b0110111) ? 32'd0 :      // LUI
                  (opcode == 7'b0010111) ? pcOut :      // AUIPC
                  readData1;

    programCounter pc (
        .clk(clk),
        .reset(reset),
        .pcIn(pcNext),
        .pcWe(1'b1),
        .pcOut(pcOut)
    );

    instMem imem (
        .addr(pcOut),
        .inst(inst)
    );

    assign instOut = inst;

    regFile rf (
        .clk(clk),
        .reset(reset),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .writeData(regWriteData),
        .regWriteEn(regWriteEn),
        .readData1(readData1),
        .readData2(readData2)
    );

    immGen ig (
        .inst(inst),
        .imm(imm)
    );

    control_unit ctrl (
        .opcode(opcode),
        .funct3(funct3),
        .regWriteEn(regWriteEn),
        .aluSrc(aluSrc),
        .aluOp(aluOp),
        .memRead(memRead),
        .memWrite(memWrite),
        .memToReg(memToReg),
        .memCtrl(memCtrl),
        .jalTaken(jalTaken)
    );

    alu_control alu_ctrl (
        .aluOp(aluOp),
        .funct3(funct3),
        .funct7(funct7[6:0]),
        .aluCtrl(aluCtrl)
    );

    assign aluB = aluSrc ? imm : readData2;

    alu myAlu (
        .a(aluA),
        .b(aluB),
        .aluCtrl(aluCtrl),
        .aluResult(aluResult),
        .zero(zero),
        .lt(lt),
        .ltu(ltu)
    );

    always_comb begin
        memReadData = mem_rdata;
    end

    logic branchTaken;
    always_comb begin
        case(funct3)
            3'b000: branchTaken = zero;     // BEQ
            3'b001: branchTaken = ~zero;    // BNE
            3'b100: branchTaken = lt;       // BLT
            3'b101: branchTaken = ~lt;      // BGE
            3'b110: branchTaken = ltu;      // BLTU
            3'b111: branchTaken = ~ltu;     // BGEU
            default: branchTaken = 1'b0;
        endcase
    end

    logic [31:0] jalTarget;
    logic [31:0] jalrTarget;
    assign jalrTarget = (readData1 + imm) & 32'hFFFFFFFE; // clear LSB

    assign jalTarget = pcOut + imm;   // Jump target
    assign pcPlus4 = pcOut + 32'd4;
    assign pcNext = (opcode == 7'b1100011 && branchTaken) ? (pcOut + imm) :
                    (((opcode == 7'b1100111) ? jalrTarget :(jalTaken ? jalTarget : pcPlus4)));

    assign regWriteData = (opcode == 7'b1101111 || opcode == 7'b1100111) ? pcPlus4 :
                          (memToReg ? memReadData : aluResult);

    assign aluOut = aluResult;
    assign rdout = rd;

    assign mem_cs    = memRead | memWrite;
    assign mem_we    = memWrite;         // write enable
    assign mem_addr  = aluResult;        // address comes from ALU result
    assign mem_wdata = readData2;        // store data comes from rs2

endmodule
