
//   0x640 : DATA register (write-only: sends LSB if idle)
//   0x644 : STATUS register (read-only: bit[0] = busy)

module uart_mm #(
    parameter BASE_ADDR = 32'h0000_0640
)(
    input  logic        clk,     // system clock
    input  logic        bclk,    // baud clock (slower tick for UART)
    input  logic        reset,

    input  logic        cs,
    input  logic        we,
    input  logic [31:0] addr,
    input  logic [31:0] wdata,
    output logic [31:0] rdata,

    output logic        txLine,
    output logic        busy
);


    logic [7:0] data_reg;     
    logic       send_req;     
    logic       send_ack;     

    // latch request on system clk
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            send_req <= 1'b0;
            data_reg <= 8'h00;
        end else begin
            if (cs && we && (addr == BASE_ADDR) && !busy) begin
                send_req <= 1'b1;
                data_reg <= wdata[7:0];
            end else if (send_ack) begin
                send_req <= 1'b0; // clear when uart starts
            end
        end
    end

    // synchronize request into bclk domain
    logic send_req_sync1, send_req_sync2;
    always_ff @(posedge bclk or posedge reset) begin
        if (reset) begin
            send_req_sync1 <= 1'b0;
            send_req_sync2 <= 1'b0;
        end else begin
            send_req_sync1 <= send_req;
            send_req_sync2 <= send_req_sync1;
        end
    end

    // rising edge detect in bclk domain ? pulse for uartTx
    logic send_req_sync2_d;
    always_ff @(posedge bclk or posedge reset) begin
        if (reset)
            send_req_sync2_d <= 1'b0;
        else
            send_req_sync2_d <= send_req_sync2;
    end

    wire send_pulse = send_req_sync2 & ~send_req_sync2_d;

    // ack back to system clk when we generated a pulse
    assign send_ack = send_pulse;

    uartTx uart_inst (
        .bclk   (bclk),
        .reset  (reset),
        .dataIn (data_reg),
        .send   (send_pulse),
        .txLine (txLine),
        .busy   (busy)
    );

    always_comb begin
        rdata = 32'h0;
        if (cs && !we) begin
            if (addr == (BASE_ADDR + 32'd4))
                rdata = {31'b0, busy};  // STATUS register
        end
    end

endmodule
