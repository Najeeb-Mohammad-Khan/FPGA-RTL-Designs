`include "SevenSegmentDisplay.v"
`timescale 1ns / 1ps

module SevenSegmentDisplay_tb;
    reg En, DP,Clk;
    wire [7:0]SSD;

    SevenSegmentDisplay uut(SSD,DP,En,Clk);

    initial begin
        $dumpfile("SevenSegmentDisplay_tb.vcd");
        $dumpvars(0, SevenSegmentDisplay_tb);

        $display("DataDump Started");
    end    

    always begin
        Clk = 1;
        #5;
        Clk = 0;
        #5;
    end

    initial begin   
        En = 0;
        DP = 0;

        #20;

        En = 1;

        #400;

        En = 0;

        #20;

        $finish;
    end
endmodule