/*
    We are using Basys-3 FPGA board, it has built-in 100MHz clock
    Data to be sent is :: 0x61

*/
`timescale 1ns/10ps
`include "NandlandBased_MyUART_TX.v"

module NandlandBased_MyUART_TX_tb ();
    parameter ClockPeriod_ns = 10;
    parameter ClocksPerBit = 10417;
    parameter BitPeriod = 104200;

    reg Clk;
    reg Tx_DataValid;
    wire Tx;
    reg  [7:0] Tx_Data;
    wire TxDone;
    wire [7:0] SSD_Out;
    wire [3:0] SSD_Select;
    wire [7:0] LEDOut;
    
    //Takes the data input and serialize it.
    task UART_Tx_Byte;
        integer i;
        begin
            // Extra Delay
            #(BitPeriod);
            
            Tx_DataValid = 1;
            
            //Send Start Bit
            #(BitPeriod);
            
            //Send Data Byte
            for (i = 0; i<8; i=i+1) begin
            #(BitPeriod);
            end 

            //Send Stop Bit
            #(BitPeriod);
            Tx_DataValid = 0;

            //Extra Delays
            #(BitPeriod);
            #(BitPeriod);

        end
    endtask

    //Invoking the Design Under Test
    NandlandBased_MyUART_TX uut(LEDOut, SSD_Out, SSD_Select,Tx_Data, TxDone, Tx_DataValid, Clk, Tx);

    initial begin
        #200;
        if(TxDone == 0)
        begin
            Tx_Data = 8'h61;
            UART_Tx_Byte;        
            $display("UART_TX 0x61 success !!");
        end

        else begin
            $display("UART_TX Busy, uart tx 0x61 failed");
        end

        if(TxDone == 0)
        begin
            Tx_Data = 8'h63;
            UART_Tx_Byte;        
            $display("UART_TX 0x63 success !!");
        end

        else begin
            $display("UART_TX Busy, uart tx 0x63 failed");
        end


            $finish;
    end
    

    //Clock Generation
    always #(ClockPeriod_ns/2)  Clk <= !Clk;
        
    //Required  to generate .vcd waveform file
    initial
    begin
        $dumpfile("NandlandBased_MyUART_TX_tb.vcd");
        $dumpvars(0, NandlandBased_MyUART_TX_tb);
    end

    //Setting default values
    initial begin
        Clk = 0;
        Tx_DataValid = 0;
        Tx_Data = 8'h00;
    end

endmodule