module uartTx(
    input  logic        bclk,    
    input  logic        reset,
    input  logic [7:0]  dataIn,
    input  logic        send,   
    output logic        txLine,  
    output logic        busy
);

  typedef enum logic [1:0] {stIdle, stStart, stData, stStop} statet;
    statet state, nextState;

    logic [9:0] shiftReg, nextShiftReg;
    logic [3:0] bitCnt, nextBitCnt;

    assign txLine = (state == stIdle) ? 1'b1 : shiftReg[0];
    assign busy   = (state != stIdle);

    always_comb begin
        nextState    = state;
        nextShiftReg = shiftReg;
        nextBitCnt   = bitCnt;

        case (state)
            stIdle:  if (send) begin
                         nextShiftReg = {1'b1, dataIn, 1'b0}; 
                         nextBitCnt   = 0;
                         nextState    = stStart;
                     end

            stStart: begin
                         nextShiftReg = {1'b1, shiftReg[9:1]};
                         nextBitCnt   = 1;
                         nextState    = stData;
                     end

            stData:  begin
                         nextShiftReg = {1'b1, shiftReg[9:1]};
                         if (bitCnt == 8)
                             nextState = stStop;
                         else
                             nextBitCnt = bitCnt + 1;
                     end

            stStop:  begin
                         nextShiftReg = {1'b1, shiftReg[9:1]};
                         nextState    = stIdle;
                     end
        endcase
    end

    always_ff @(posedge bclk or posedge reset) begin
        if (reset) begin
            state     <= stIdle;
            shiftReg  <= 10'b1111111111;
            bitCnt    <= 0;
        end else begin
            state     <= nextState;
            shiftReg  <= nextShiftReg;
            bitCnt    <= nextBitCnt;
        end
    end

endmodule