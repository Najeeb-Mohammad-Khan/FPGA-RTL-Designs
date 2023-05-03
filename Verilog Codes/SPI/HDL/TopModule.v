`timescale 1ns / 1ps

module TopModule(EN, StartFlag, Master_Data_Correct, Slave_Data_Correct, CLK_IN);

    wire CPOL, CPHA;
    input StartFlag;
    output Master_Data_Correct,Slave_Data_Correct;

    wire Data_Correct;
    reg Data_Correct_Reg;

    assign Data_Correct = Data_Correct_Reg;

    wire SCK, MOSI, MISO, ChipSel;
    
    wire Slave_TxData;
    wire Slave_RxData;
    input EN;
    input CLK_IN;

    wire Master_DataValid;
    wire Master_SPI_Done;

    wire Slave_DataValid;
    wire Master_Data_Correct;
    wire Slave_Data_Correct;
    wire Slave_SPI_Done;

    SPI_MASTER2 uut_Master  (.StartFlag(StartFlag), .SCK(SCK), .MOSI(MOSI), .MISO(MISO),
                    .ChipSel(ChipSel), .Master_RxData(Master_RxData), .EN(EN), .CLK_IN(CLK_IN), .SPI_Done(Master_SPI_Done), .DataValid(Master_DataValid), .Data_Correct(Master_Data_Correct));

    SPI_SLAVE2  uut_Slave   (.StartFlag(StartFlag), .SCK(SCK), .MOSI(MOSI), .MISO(MISO),
                    .ChipSel(ChipSel), .Slave_RxData(Slave_RxData), .EN(EN), .CLK_IN(CLK_IN), .SPI_Done(Slave_SPI_Done), .DataValid(Slave_DataValid), .Data_Correct(Slave_Data_Correct));

    reg Master_Rx_Data_Correct = 0;
    reg Slave_Rx_Data_Correct = 0;

    wire [15:0] Master_RxData; 
    wire [15:0] Slave_RxData; 

endmodule
