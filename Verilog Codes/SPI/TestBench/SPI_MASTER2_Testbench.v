`timescale 1ns / 1ps

module SPI_MASTER2_Testbench();

    parameter ClockPeriod_ns = 10;

    reg CPOL, CPHA;

    reg CLK_IN;
    reg EN;
    reg StartFlag;
    reg [15:0] Master_TxData;
    reg [15:0] Slave_TxData;
    wire Master_SPI_Done, Slave_SPI_Done;
    wire SCK;
    wire MOSI;
    // reg MISO;
    wire MISO;
    wire Slave_MISO;
    wire ChipSel;
    reg [15:0] TxData;
    wire [15:0] Master_RxData; 
    wire [15:0] Slave_RxData; 

    reg Master_Rx_Data_Correct;
    reg Slave_Rx_Data_Correct;
    
    //Clock Generation
    always #(ClockPeriod_ns/2)  CLK_IN <= !CLK_IN;

            //OR
    // initial
    // begin
    //     forever #(ClockPeriod_ns/2)  CLK_IN = !CLK_IN;        
    // end

    //uut SPI MASTER
    // SPI_MASTER2 uut (.StartFlag(StartFlag), .SCK(SCK), .MOSI(MOSI), .MISO(MISO),
    //                 .ChipSel(ChipSel), .Master_RxData(Master_RxData), .EN(EN), .CLK_IN(CLK_IN), .SPI_Done(Master_SPI_Done));

    SPI_MASTER2 uut_Master  (.CPOL(CPOL), .CPHA(CPHA), .StartFlag(StartFlag), .SCK(SCK), .MOSI(MOSI), .MISO(MISO),
                    .ChipSel(ChipSel), .Master_TxData(Master_TxData),.Master_RxData(Master_RxData), .EN(EN), .CLK_IN(CLK_IN), .SPI_Done(Master_SPI_Done));

    SPI_SLAVE2  uut_Slave   (.CPOL(CPOL), .CPHA(CPHA), .StartFlag(StartFlag), .SCK(SCK), .MOSI(MOSI), .MISO(MISO),
                    .ChipSel(ChipSel), .Slave_TxData(Slave_TxData), .Slave_RxData(Slave_RxData), .EN(EN), .CLK_IN(CLK_IN), .SPI_Done(Master_SPI_Done));

    //Required  to generate .vcd waveform file
    initial
    begin
        $dumpfile("SPI_MASTER2_Testbench.vcd");
        $dumpvars(0, SPI_MASTER2_Testbench);
    end


    initial begin
        EN = 0;
        CLK_IN = 0;
        // MISO = 1;
        StartFlag = 0;

        Master_Rx_Data_Correct  = 0;
        Slave_Rx_Data_Correct   = 0;
    end


    initial begin
        //Start 2nd SPI
        Master_TxData   = 16'b1010100110100101;
        Slave_TxData    = 16'b1111000010100101;
        CPOL = 0;
        CPHA = 0;
        #4000;

        EN = 1;
        StartFlag = 1;
        #10;
        StartFlag = 0;
        #8000; //End of First SPI TEST


        //Start 2nd SPI
        Master_TxData   = 16'b1100110010100111;
        Slave_TxData    = 16'b1001000010110111;
        CPOL = 0;
        CPHA = 1;
        #4000;

        EN = 1;
        StartFlag = 1;
        #10;
        StartFlag = 0;
        #8000; //End of Second SPI TEST

        //Start 3rd SPI
        Master_TxData   = 16'b1110111110100100;
        Slave_TxData    = 16'b0110110010001111;
        CPOL = 1;
        CPHA = 0;
        #4000;

        EN = 1;
        StartFlag = 1;
        #10;
        StartFlag = 0;
        #8000; //End of Second SPI TEST

        //Start 4th SPI
        Master_TxData   = 16'b1010101110100010;
        Slave_TxData    = 16'b1001010011100001;
        CPOL = 1;
        CPHA = 1;
        #4000;
        
        EN = 1;
        StartFlag = 1;
        #10;
        StartFlag = 0;
        #8000; //End of Second SPI TEST

        $finish;
    end


    always @(Master_RxData, Master_TxData, Slave_RxData, Slave_TxData) 
    begin
        if(Master_RxData == Slave_TxData)
        begin
            Master_Rx_Data_Correct = 1;
        end
        else begin
            Master_Rx_Data_Correct = 0;
        end 

        if(Slave_RxData == Master_TxData)
        begin
            Slave_Rx_Data_Correct = 1;
        end
        else begin
            Slave_Rx_Data_Correct = 0;
        end 
    end
endmodule