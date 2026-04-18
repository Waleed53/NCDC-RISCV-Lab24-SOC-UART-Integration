module instMem #(
    parameter DEPTH = 256
) (
    input  logic [31:0] addr,
    output logic [31:0] inst
);

    logic [31:0] mem [0:DEPTH-1];

    initial begin
        integer i;
        for (i = 0; i < DEPTH; i++) mem[i] = 32'h00000013; // default values (nop)

// Testing load functionality
/*
mem[0] = 32'b000000000000_00000_010_00001_0000011;  // lw  x1, 0(x0)   - load word from addr 0
mem[1] = 32'b000000000100_00000_010_00010_0000011;  // lw  x2, 4(x0)   - load word from addr 4
mem[2] = 32'b000000001000_00000_010_00011_0000011;  // lw  x3, 8(x0)   - load word from addr 8

mem[3] = 32'b000000000000_00000_001_00100_0000011;  // lh  x4, 0(x0)   - load halfword from addr 0
mem[4] = 32'b000000000010_00000_001_00101_0000011;  // lh  x5, 2(x0)   - load halfword from addr 2

mem[5] = 32'b000000000000_00000_101_00110_0000011;  // lhu x6, 0(x0)   - load halfword unsigned from addr 0
mem[6] = 32'b000000000010_00000_101_00111_0000011;  // lhu x7, 2(x0)   - load halfword unsigned from addr 2

mem[7] = 32'b000000000000_00000_000_01000_0000011;  // lb  x8, 0(x0)   - load byte from addr 0
mem[8] = 32'b000000000001_00000_000_01001_0000011;  // lb  x9, 1(x0)   - load byte from addr 1
mem[9] = 32'b000000000010_00000_000_01010_0000011;  // lb  x10, 2(x0)  - load byte from addr 2
mem[10]= 32'b000000000011_00000_000_01011_0000011;  // lb  x11, 3(x0)  - load byte from addr 3

mem[11]= 32'b000000000000_00000_100_01100_0000011;  // lbu x12, 0(x0)  - load byte unsigned from addr 0
mem[12]= 32'b000000000001_00000_100_01101_0000011;  // lbu x13, 1(x0)  - load byte unsigned from addr 1
mem[13]= 32'b000000000010_00000_100_01110_0000011;  // lbu x14, 2(x0)  - load byte unsigned from addr 2
mem[14]= 32'b000000000011_00000_100_01111_0000011;  // lbu x15, 3(x0)  - load byte unsigned from addr 3
*/

//mem[0] = 32'h000002B7; 
//mem[1] = 32'h0AB28293; 
//mem[2] = 32'h00000337; 
//mem[3] = 32'h64030313; 
//mem[4] = 32'h00532023; 
//mem[5] = 32'h00430E13; 
//mem[6] = 32'h000E2283; 
//mem[7] = 32'hFE031AE3; 
//mem[8] = 32'hFF5FF06F; 

    mem[0] = 32'h00000337; // lui   t1,0
    mem[1] = 32'h64030313; // addi  t1,t1,0x640
    mem[2] = 32'h0AB00293; // addi  t0,x0,0xAB   (li t0,0xAB)
    mem[3] = 32'h00532023; // sw    t0,0(t1)     (write to 0x640)
    mem[4] = 32'h00430E13; // addi  t2,t1,4      (t2=0x644)
    mem[5] = 32'h000E2283; // lw    t3,0(t2)     (read status)
    //mem[6] = 32'hFE5FF06F; // j     loop (infinite loop back)




//mem[0] = 32'b00000000010100000000_00010_0010011; // 00500113   addi x2, x0, 5
//mem[1] = 32'b00000000110000000000_00011_0010011; // 00C00193 addi x3, x0, 12

//mem[2] = 32'b11111111011100011000001110010011; // FF718393 addi x7, x3, -9
//mem[3] = 32'b00000000001000111110001000110011; // 0023E233 or x4, x7, x2
//mem[4] = 32'b00000000010000011111001010110011; // 0x0041F2B3 and x5, x3, x4
//mem[5] = 32'b00000000010000101000001010110011; // 0x004282B3 add x5, x5, x4
//mem[6] = 32'b00000010011100101000100001100011; // 0x02728863 beq x5, x7, end (end = 48)
//mem[7] = 32'b00000000010000011010001000110011; // 0x0041A233 slt x4, x3, x4
//mem[8] = 32'b00000000000000100000010001100011; // 0x00020463 beq x4, x0, around (around = 28)
//mem[9] = 32'b00000000000000000000001010010011; // 0x00000293 addi x5, x0, x0
//mem[10] = 32'b00000000001000111010001000110011; // 0x0023A233 slt x4, x7, x2  
//mem[11] = 32'b00000000010100100000001110110011; // 0x005203B3 add x7, x4, x5
//mem[12] = 32'b01000000001000111000001110110011; // 0x402383B3 sub x7, x2, x2
//mem[13] = 32'b00000100011100011010101000100011; // 0x0471AA23 sw x7, 84(x3)
//mem[14] = 32'b00000110000000000010000100000011; // 0x0471AA23 lw x2, 96(x0)
//mem[15] = 32'b00000000010100010000010010110011; // 0x005104B3 add x9, x2, x5
//mem[16] = 32'b00000000100000000000000111101111; // 0x008001EF jal x3, end (end = 48)
//mem[17] = 32'b00000000000100000000000100010011; // 0x00100113 addi x2, x0, 1
//mem[18] = 32'b00000000100100010000000100110011; // 0x00910133 add x2, x2, x9, result stored in x2 should 25
//mem[19] = 32'b00000010001000011010000000100011; // 0x0221A023 sw x2, 0x20(x3)
//mem[20] = 32'b00000000001000010000000001100011; // 0x00210063 beq x2, x2, done




    end

    assign inst = mem[addr[31:2]];
    
initial begin
    $display("mem[0]=%h", mem[0]);
    $display("mem[1]=%h", mem[1]);
end

endmodule