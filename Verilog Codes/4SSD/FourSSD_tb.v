`timescale 1ns/10ps
`include "FourSSD.v"

module FourSSD_tb();
    reg[15:0] DataIn;
    reg En, Clk;
    reg [3:0] SSD_DP;
    wire [7:0] SSD_Out;
    wire [3:0] SSD_Select;

    FourSSD uut(SSD_Out,SSD_Select,SSD_DP,DataIn,En,Clk);

    //Giving Default Conditions
    initial begin
        $dumpfile("FourSSD_tb.vcd");
        $dumpvars(0, FourSSD_tb);        
        $display("DataDump Started");
    end    

    //Generating Clock
    always begin
        Clk = 1;
        #5;
        Clk = 0;
        #5;
    end

    initial begin   
        En = 0;
        DataIn = 16'hABCD;
        SSD_DP = 4'b0101;
        #20;

        En = 1;
        #50000000;

        $finish;
    end

endmodule