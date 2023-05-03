module RisingEdgeDetector(
    RiseEdgeDectected, SignalInput, En, Clk
);
    output wire RiseEdgeDectected;
    input wire SignalInput;
    input wire En, Clk;

    reg RiseEdgeDectected_Reg;
//    reg Inter_Signal;

    assign RiseEdgeDectected = (~RiseEdgeDectected_Reg & SignalInput);

    initial begin
        RiseEdgeDectected_Reg = 1;
    end

    always @(posedge Clk) begin
        RiseEdgeDectected_Reg <= SignalInput;
    end


endmodule