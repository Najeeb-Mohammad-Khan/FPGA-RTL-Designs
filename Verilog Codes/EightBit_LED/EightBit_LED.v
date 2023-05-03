`include "HunderedMHz_To_OneHz.v"

module EightBit_LED(
    LEDOut, DataIn, En, Clk 
);
    output wire [7:0]LEDOut;
    input wire [7:0]DataIn;
    input wire En, Clk;

    wire SlowClk;
    reg [7:0] InterLED; 

    HunderedMHz_To_OneHz uut(SlowClk,Clk,En);

    assign LEDOut = InterLED;

    always @(posedge SlowClk) begin
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