`timescale 1ns / 1ps

module I2C_Master_Top
(  
    SDA, SCL, Read_WriteBar, WriteData, ReadData, StartFlag, EN, CLK_IN
);

    output wire [7:0] ReadData;
    input wire [7:0] WriteData;
    input wire EN;
    input wire Read_WriteBar;
    input wire CLK_IN;

    reg [6:0] SlaveAddr;
    inout wire SDA;
    output wire SCL;
    wire DoneFlag;
    input wire StartFlag;

    initial begin
        SlaveAddr = 7'b0101000;        
    end

    I2C_Master uut (.SDA(SDA), .SCL(SCL), .SlaveAddr(SlaveAddr), .Read_WriteBar(Read_WriteBar),
                 .WriteData(WriteData), .ReadData(ReadData), .StartFlag(StartFlag),
                 .DoneFlag(DoneFlag), .EN(EN), .CLK_IN(CLK_IN)
                );

               
endmodule
