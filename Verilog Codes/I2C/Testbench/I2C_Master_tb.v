`timescale 1ns / 10ps

module I2C_Master_tb();
    parameter ClockPeriod_ns = 10;
    parameter StandardMode_BitRate_100Kbps  = 100;
    parameter FastMode_BitRate_400Kbps      = 400;
    parameter FastModePlus_BitRate_1Mbps    = 1000;

    localparam BitRateMode_Kbps = FastMode_BitRate_400Kbps;

    parameter Positive_ACK = 0; //SDA Pulled Down
    parameter Negative_ACK = 1; //SDA not Pulled Down

    reg EN;
    reg Clk;
    reg [6:0] SlaveAddr;

    wire SDA;
    wire SCL;
    reg SDA_Reg;
    reg Read_WriteBar;
    reg  [7:0] WriteData;
    wire [7:0] ReadData;
    reg StartFlag;
    wire DoneFlag;

    reg GiveSlaveACK;

    assign SDA = GiveSlaveACK ? SDA_Reg : 1'bZ ;

    I2C_Master #(BitRateMode_Kbps) uut(.SDA(SDA), .SCL(SCL), .SlaveAddr(SlaveAddr),
                                       .Read_WriteBar(Read_WriteBar), .EN(EN),
                                       .WriteData(WriteData), .ReadData(ReadData), 
                                       .CLK_IN(Clk), .StartFlag(StartFlag), .DoneFlag(DoneFlag));

    //Required  to generate .vcd waveform file
    initial
    begin
        $dumpfile("I2C_Master_tb.vcd");
        $dumpvars(0, I2C_Master_tb);
    end

    //Clock Generation (100MHz Clock)
    always #(ClockPeriod_ns/2)  Clk <= !Clk;

    //Setting default values
    initial begin
        Clk = 0;
        EN = 1;
        SDA_Reg = Negative_ACK;
        GiveSlaveACK = 0;
        SlaveAddr = 7'b1010101;
        Read_WriteBar = 1;

        WriteData = 8'b11001010;
        StartFlag = 0;
    end

    initial begin
        #10;
        StartFlag = 1;
        #10;
        StartFlag = 0;        

        #50000;
        StartFlag = 1;
        #10;
        StartFlag = 0;        

    end

    initial begin
        // #21185;
         #21195;
        GiveSlaveACK = 1;
        SDA_Reg = Positive_ACK;

        // #2530;
//        #(23695 - 21195);
        #(31195 - 21195);
        SDA_Reg = Negative_ACK;

        #(43625 - 31195);
        SDA_Reg = Negative_ACK;

        GiveSlaveACK = 0;              
    end

    initial begin
        #100000;
        $finish;
    end

endmodule
