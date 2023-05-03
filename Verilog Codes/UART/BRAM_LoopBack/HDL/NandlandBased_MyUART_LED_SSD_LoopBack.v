`include "NandlandBased_MyUART_LED_SSD.v"
`include "NandlandBased_MyUART_TX.v"

module NandlandBased_MyUART_LED_SSD_LoopBack(
    LEDOut, SSD_Out, SSD_Select, TxDone, Tx, Rx, En, Clk
);
    input wire Clk;
    input wire En;
    input wire Rx;

    output wire TxDone;
    output wire Tx;
    output wire [7:0] LEDOut;
    output wire [7:0] SSD_Out;
    output wire [3:0] SSD_Select;
    
    wire RxDataValid;
    wire [7:0] Rx_Buffer;
    
    NandlandBased_MyUART_LED_SSD uut(Rx_Buffer, RxDataValid, LEDOut, SSD_Out, SSD_Select, Clk, Rx, En);

    NandlandBased_MyUART_TX uut2(Rx_Buffer, TxDone, RxDataValid, Clk, Tx);


endmodule