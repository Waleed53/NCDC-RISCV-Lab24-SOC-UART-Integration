module programCounter (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] pcIn,
    input  logic        pcWe,
    output logic [31:0] pcOut
);

    logic [31:0] pcReg;

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            pcReg <= 32'h0;
        else if (pcWe)
            pcReg <= pcIn;
    end

    assign pcOut = pcReg;

endmodule
