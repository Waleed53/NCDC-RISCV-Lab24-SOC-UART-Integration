module soc_top (
    input  logic clk,
    input  logic reset
);

    logic [31:0] pcOut, instOut, aluOut;
    logic        regWriteEn;
    logic [31:0] regWriteData;
    logic [4:0]  rdout;

    logic        mem_cs;
    logic        mem_we;
    logic [31:0] mem_addr;
    logic [31:0] mem_wdata;
    logic [31:0] mem_rdata;

    top core_inst (
        .clk(clk),
        .reset(reset),
        .pcOut(pcOut),
        .instOut(instOut),
        .aluOut(aluOut),
        .regWriteEn(regWriteEn),
        .regWriteData(regWriteData),
        .rdout(rdout),

        .mem_cs(mem_cs),
        .mem_we(mem_we),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_rdata(mem_rdata)
    );

    localparam UART_BASE = 32'h0000_0640;
    localparam UART_TOP  = 32'h0000_0644;

    logic sel_uart, sel_dmem;
    assign sel_uart = mem_cs && (mem_addr >= UART_BASE && mem_addr <= UART_TOP);
    assign sel_dmem = mem_cs && !sel_uart;

    logic [31:0] uart_rdata;
    logic        uart_txLine;
    logic        uart_busy;
    logic bclk;

baudgen #(.DIV(16)) baud_inst (
        .clk(clk),
        .reset(reset),
        .bclk(bclk)
    );

    uart_mm uart_inst (
        .clk   (clk),
        .bclk(bclk),
        .reset (reset),
        .cs    (sel_uart),
        .we    (mem_we),
        .addr  (mem_addr),
        .wdata (mem_wdata),
        .rdata (uart_rdata),
        .txLine(uart_txLine),
        .busy  (uart_busy)
    );

    logic [31:0] dmem_rdata;

    dataMem dmem_inst (
        .clk      (clk),
        .reset    (reset),
        .addr     (mem_addr),
        .writeData(mem_wdata),
        .memRead  (sel_dmem && !mem_we),
        .memWrite (sel_dmem && mem_we),
        .memCtrl  (3'b010),   // example: word access; adapt if needed
        .readData (dmem_rdata)
    );

    always_comb begin
        if (sel_uart)
            mem_rdata = uart_rdata;
        else if (sel_dmem)
            mem_rdata = dmem_rdata;
        else
            mem_rdata = 32'h0;
    end

endmodule


module baudgen #(parameter DIV=16)(
    input  logic clk,
    input  logic reset,
    output logic bclk
);
    logic [$clog2(DIV)-1:0] cnt;
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            cnt <= 0;
            bclk <= 0;
        end else begin
            if (cnt == DIV-1) begin
                cnt <= 0;
                bclk <= ~bclk; // toggle bclk
            end else begin
                cnt <= cnt + 1;
            end
        end
    end
endmodule
