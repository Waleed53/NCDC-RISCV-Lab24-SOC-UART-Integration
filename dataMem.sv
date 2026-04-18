module dataMem #(
    parameter DEPTH = 256
) (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] addr,
    input  logic [31:0] writeData,
    input  logic        memRead,
    input  logic        memWrite,
    input  logic [2:0]  memCtrl,
    output logic [31:0] readData
);

    logic [31:0] mem [0:DEPTH-1];
    logic [31:0] wordData;
    logic [1:0]  byteOffset;
    logic [15:0] halfword;
    logic [7:0]  byteData;

    initial begin
        integer i;
        for (i = 0; i < DEPTH; i++) mem[i] = 32'h0;
        
        mem[0] = 32'hDEADBEEF;  // Address 0
        mem[1] = 32'h12345678;  // Address 4  
        mem[2] = 32'hABCDEF01;  // Address 8
        mem[3] = 32'h87654321;  // Address 12
    end

    wire [29:0] wordAddr = addr[31:2];  // Word address (divide by 4)
    assign byteOffset = addr[1:0];      // Byte offset within word


    assign wordData = mem[wordAddr];

    always_ff @(posedge clk) begin
        if (memWrite) begin
            case (memCtrl)
                3'b010: begin // sw (store word)
                    mem[wordAddr] <= writeData;
                end
                3'b001: begin // sh (store halfword)
                    case (byteOffset[1])
                        1'b0: mem[wordAddr][15:0]  <= writeData[15:0];   // Lower halfword
                        1'b1: mem[wordAddr][31:16] <= writeData[15:0];   // Upper halfword
                    endcase
                end
                3'b000: begin // sb (store byte)
                    case (byteOffset)
                        2'b00: mem[wordAddr][7:0]   <= writeData[7:0];
                        2'b01: mem[wordAddr][15:8]  <= writeData[7:0];
                        2'b10: mem[wordAddr][23:16] <= writeData[7:0];
                        2'b11: mem[wordAddr][31:24] <= writeData[7:0];
                    endcase
                end
                default: begin
                    // No operation for other funct3 values
                end
            endcase
        end
    end

    always_comb begin
        readData = 32'b0; // Default value
        if (memRead) begin
            case (memCtrl)
                3'b010: begin // lw (load word)
                    readData = wordData;
                end
                3'b001: begin // lh (load halfword, sign extended)
                    case (byteOffset[1])
                        1'b0: halfword = wordData[15:0];   // Lower halfword
                        1'b1: halfword = wordData[31:16];  // Upper halfword
                    endcase
                    readData = {{16{halfword[15]}}, halfword}; // Sign extend
                end
                3'b101: begin // lhu (load halfword unsigned)
                    case (byteOffset[1])
                        1'b0: halfword = wordData[15:0];   // Lower halfword
                        1'b1: halfword = wordData[31:16];  // Upper halfword
                    endcase
                    readData = {16'b0, halfword}; // Zero extend
                end
                3'b000: begin // lb (load byte, sign extended)
                    case (byteOffset)
                        2'b00: byteData = wordData[7:0];
                        2'b01: byteData = wordData[15:8];
                        2'b10: byteData = wordData[23:16];
                        2'b11: byteData = wordData[31:24];
                    endcase
                    readData = {{24{byteData[7]}}, byteData}; // Sign extend
                end
                3'b100: begin // lbu (load byte unsigned)
                    case (byteOffset)
                        2'b00: byteData = wordData[7:0];
                        2'b01: byteData = wordData[15:8];
                        2'b10: byteData = wordData[23:16];
                        2'b11: byteData = wordData[31:24];
                        default: byteData = 8'b0;
                    endcase
                    readData = {24'b0, byteData}; // Zero extend
                end
                default: begin
                    readData = 32'b0;
                end
            endcase
        end else begin
            readData = 32'b0;
        end
    end

endmodule