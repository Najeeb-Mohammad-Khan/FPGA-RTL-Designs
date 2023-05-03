/*
    We are using Basys-3 FPGA board, it has built-in 100MHz clock
    Data to be sent is :: 0x61

*/
`timescale 1ns/10ps

module UART_BRAM_LOOPBACK_tb ();
    parameter ClockPeriod_ns = 10;
    parameter ClocksPerBit = 10417;
    parameter BitPeriod = 104200;

    reg Clk;
    reg Rx,En;
    //wire [7:0] RxDataOut;
    wire [7:0] LEDOut;
    wire Tx,TxDone;
    wire [3:0] SSD_Select;
    wire [7:0] SSD_Out;

    //Takes the data input and serialize it.
    task UART_Write_Byte;
        input [7:0] Data;
        integer i;
        begin
            //Send Start Bit
            Rx <= 0;
            #(BitPeriod);
            
            //Send Data Byte
            for (i = 0; i<8; i=i+1) begin
                Rx <= Data[i];
                #(BitPeriod);
            end 

            //Send Stop Bit
            Rx <= 1;
            #(BitPeriod);
        end
    endtask

    task UART_Tx_Test;
        integer i;
        for (i = 0; i<11; i=i+1) begin
            #(BitPeriod);
        end 
    endtask

    //Invoking the Design Under Test
    UART_BRAM_LOOPBACK uut(LEDOut, SSD_Out, SSD_Select, TxDone, Tx, Rx, En, Clk);

    //Clock Generation
    always #(ClockPeriod_ns/2)  Clk <= !Clk;

    //Main Testing Module
    initial begin
        //Sending the RX Command to the UART
        @(posedge Clk); //At positive edge of the clock
        UART_Write_Byte(8'h61); //Send 0x61 hex data to the dut uart
        // @(posedge Clk); //At positive edge of the clock
        // UART_Tx_Test;
        // @(posedge Clk); //At positive edge of the clock


        //Sending the RX Command to the UART
        @(posedge Clk); //At positive edge of the clock
        UART_Write_Byte(8'h62); //Send 0x61 hex data to the dut uart
        // @(posedge Clk); //At positive edge of the clock
        // UART_Tx_Test;
        // @(posedge Clk); //At positive edge of the clock


        //Sending the RX Command to the UART
        @(posedge Clk); //At positive edge of the clock
        UART_Write_Byte(8'h63); //Send 0x61 hex data to the dut uart
        // @(posedge Clk); //At positive edge of the clock
        // UART_Tx_Test;
        // @(posedge Clk); //At positive edge of the clock


        //Sending the RX Command to the UART
        @(posedge Clk); //At positive edge of the clock
        UART_Write_Byte(8'h64); //Send 0x61 hex data to the dut uart
        // @(posedge Clk); //At positive edge of the clock
        // UART_Tx_Test;
        // @(posedge Clk); //At positive edge of the clock


        //Sending the RX Command to the UART
        @(posedge Clk); //At positive edge of the clock
        UART_Write_Byte(8'h65); //Send 0x61 hex data to the dut uart
        // @(posedge Clk); //At positive edge of the clock
        // UART_Tx_Test;
        // @(posedge Clk); //At positive edge of the clock


        //Sending the RX Command to the UART
        @(posedge Clk); //At positive edge of the clock
        UART_Write_Byte(8'h66); //Send 0x61 hex data to the dut uart
        // @(posedge Clk); //At positive edge of the clock
        // UART_Tx_Test;
        // @(posedge Clk); //At positive edge of the clock


        //Sending the RX Command to the UART
        @(posedge Clk); //At positive edge of the clock
        UART_Write_Byte(8'h67); //Send 0x61 hex data to the dut uart
        // @(posedge Clk); //At positive edge of the clock
        // UART_Tx_Test;
        // @(posedge Clk); //At positive edge of the clock


        //Sending the RX Command to the UART
        @(posedge Clk); //At positive edge of the clock
        UART_Write_Byte(8'h68); //Send 0x61 hex data to the dut uart
        // @(posedge Clk); //At positive edge of the clock
        // UART_Tx_Test;
        // @(posedge Clk); //At positive edge of the clock

        @(posedge Clk); //At positive edge of the clock
        UART_Tx_Test;

        @(posedge Clk); //At positive edge of the clock
        UART_Tx_Test;

        @(posedge Clk); //At positive edge of the clock
        UART_Tx_Test;

        @(posedge Clk); //At positive edge of the clock
        UART_Tx_Test;

        @(posedge Clk); //At positive edge of the clock
        UART_Tx_Test;

        @(posedge Clk); //At positive edge of the clock
        UART_Tx_Test;

        @(posedge Clk); //At positive edge of the clock
        UART_Tx_Test;

        @(posedge Clk); //At positive edge of the clock
        UART_Tx_Test;

        @(posedge Clk); //At positive edge of the clock
        $finish;
    end
        
    //Required  to generate .vcd waveform file
    initial
    begin
        $dumpfile("UART_BRAM_LOOPBACK_tb.vcd");
        $dumpvars(0, UART_BRAM_LOOPBACK_tb);
    end

    //Setting default values
    initial begin
        Clk = 0;
        Rx = 1;
        En = 1;
    end

endmodule