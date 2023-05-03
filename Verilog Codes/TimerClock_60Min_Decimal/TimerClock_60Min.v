`timescale 1ns/10ps
`include "FourSSD.v"
`include "HunderedMHz_To_OneHz.v"
`include "HunderedMHz_To_TenHz.v"
`include "TwoDigit_DeciamlCounter.v"

module TimerClock_60Min(
    SSD_Out,SSD_Select,TimerUpFlag,Clk_Select,En,Clk
);
    input wire En;
    input wire Clk; 
    input wire Clk_Select;
    output wire [7:0] SSD_Out;
    output wire [3:0] SSD_Select;
    output wire TimerUpFlag;

    reg [3:0] SSD_DP;
    reg [15:0] DataIn;
    reg [7:0] Min_Counter, Sec_Counter;
    wire OneHz_SlowClk,TenHz_SlowClk;
    reg TimerClk;
    reg TimerCompleted_Flag;
    reg SecCounterEn;
    reg MinCounterEn;

    wire [7:0] TimerSec_CountOut;
    wire [7:0] TimerMin_CountOut;

    FourSSD uut(SSD_Out,SSD_Select,SSD_DP,DataIn,En,Clk);
    HunderedMHz_To_OneHz uut2(OneHz_SlowClk, Clk, En);
    HunderedMHz_To_TenHz uut3(TenHz_SlowClk, Clk, En);
    TwoDigit_DeciamlCounter uut4(TimerSec_CountOut, SecCounterEn, TimerClk);
    TwoDigit_DeciamlCounter uut5(TimerMin_CountOut, MinCounterEn, Clk);


    initial
    begin
        Min_Counter = 0;
        Sec_Counter = 0;
        TimerCompleted_Flag = 0;
        DataIn = 0;
        SSD_DP = 0;

        SecCounterEn = 1;
        MinCounterEn = 1;
    end

    assign TimerUpFlag = TimerCompleted_Flag;
    
    always @(posedge Clk)
    begin
        if(Clk_Select == 1'b1)
        begin
            TimerClk = TenHz_SlowClk;
        end
        
        else begin
            TimerClk = OneHz_SlowClk;
        end
    end
    
    always @(Min_Counter,Sec_Counter,En) begin
        if(En == 1)
        begin
            DataIn = {Min_Counter,Sec_Counter};    
        end
        else begin
            DataIn = 0;    
        end        
    end

    always @(posedge TimerClk) begin
        Sec_Counter = TimerSec_CountOut;

        if(Sec_Counter == 96)
        begin
            SecCounterEn  = 0;
        end

        else begin
            
        end

    end


    // always @(posedge TimerClk) begin
    //     if(En == 1)
    //     begin
    //         if(Sec_Counter == 60)
    //         begin
    //             Sec_Counter = 0;
    //             if(Min_Counter == 60)
    //             begin
    //                 Min_Counter = 0;
    //                 TimerCompleted_Flag = 1;
    //             end

    //             else begin
    //                 Min_Counter = Min_Counter + 1;                
    //             end
    //         end

    //         else begin
    //             if(Sec_Counter < 10)
    //             begin
    //                 Sec_Counter = Sec_Counter + 1;                
    //             end

    //             else begin
    //                 Sec_Counter = 0;                                    
    //             end
    //         end
    //     end

    //     else begin
    //         Sec_Counter = 0;
    //         Min_Counter = 0;
    //         TimerCompleted_Flag = 0;
    //     end
    // end
endmodule