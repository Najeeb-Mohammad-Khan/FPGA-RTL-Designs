module EightBit_LED(
    LEDOut, DataIn, En, Clk 
);
    output wire [7:0]LEDOut;
    input wire [7:0]DataIn;
    input wire En, Clk;

    reg [7:0] InterLED;

    initial begin
        InterLED = 0;
    end 

    assign LEDOut = InterLED;

    always @(posedge Clk) begin
        InterLED<= 0;

        if(En == 1'b1)
        begin        
            InterLED <= DataIn;
        end
        else begin
            InterLED <= 0;
        end
    end

endmodule