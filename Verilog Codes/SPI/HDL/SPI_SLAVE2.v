`timescale 1ns / 1ps

module SPI_SLAVE2#(
    parameter BitRate_Kbps = 3000,       // 3MHz default clock speed
    parameter CPOL = 0,
    parameter CPHA = 0

            //OR

    // parameter BitRate_Kbps = 3000       // 3MHz default clock speed
)
    // (StartFlag, SCK, MOSI, MISO, ChipSel, Master_RxData,EN, CLK_IN, DataValid, SPI_Done);
    // (CPOL, CPHA, StartFlag, SCK, MOSI, MISO, ChipSel, Slave_TxData, Slave_RxData,EN, CLK_IN, DataValid, SPI_Done);
    (StartFlag, SCK, MOSI, MISO, ChipSel, Slave_RxData,EN, CLK_IN, DataValid, SPI_Done, Data_Correct);

    // input wire CPOL;
    // input wire CPHA;
    // input wire [15:0] Slave_TxData;

    input wire StartFlag;
    input wire SCK;
    input wire MOSI;
    output wire MISO;
    input wire ChipSel;
    output wire [15:0] Slave_RxData;
    input wire EN;
    input wire CLK_IN;
    output wire DataValid;
    output wire SPI_Done;

    output Data_Correct;
    reg MOSI_CPOL = 0;

    //Ouput Regs
    wire SCK_Affective;
    reg MISO_Reg                    = 0;
    reg ChipSel_Reg                 = 1;    //Active Low Chip Select, Hence Default will be 1
    reg [15:0] Slave_RxData_Reg     = 0;
    reg DataValid_Reg               = 0;
    reg SPI_Done_Reg                = 0;
    reg SPI_ReadWrite_Data          = 0;
    reg Clk_Invert                  = 0;

    reg [15:0]  Master_TxData   = 16'b1010100110100101;
    reg  [15:0]  Slave_TxData  = 16'b1111000010100101;
    reg Data_Correct_Reg = 0;

    //Ouput assigns for wires
    assign MISO = MISO_Reg;
    assign ChipSel = ChipSel_Reg;
    assign Slave_RxData = Slave_RxData_Reg; 
    assign DataValid = DataValid_Reg;
    assign SPI_Done = SPI_Done_Reg;
    assign SCK_Affective = ((CPHA ^ CPOL)? ~SCK : SCK);

    //Counters
    reg [13:0] ClockCounter1 = 0;
    reg [1:0] StateMachine = 0;
    reg [4:0] BitIndex = 0;

    //State Machines Parameters
    parameter Idle       = 2'b00;
    parameter StartBit   = 2'b01;
    parameter DataBits   = 2'b10;
    parameter StopBit    = 2'b11;

    parameter ClocksPerBit = (100_000_000 / (BitRate_Kbps * 1000));
    parameter  SCK_FullPulseWidth = (ClocksPerBit);

    wire StartFlag_RiseEdgeDectected;

    RisingEdgeDetector uut (StartFlag_RiseEdgeDectected, StartFlag, EN, CLK_IN);

    always @ (posedge SPI_Done)
    begin
        if(Slave_RxData == Master_TxData)
        begin
            Data_Correct_Reg = 1;
        end
    end

    always @(posedge CLK_IN)
    begin
        if(ChipSel_Reg == 0)
        begin            
            if(ClockCounter1 < (SCK_FullPulseWidth - 1)/2)    //We have reached the middle of the StartBit
            begin
                ClockCounter1 <= ClockCounter1 + 1;
            end
            
            else 
            begin
                ClockCounter1 <= 0;            
            end
        end
    end

    always @(posedge CLK_IN) begin
        if((StartFlag_RiseEdgeDectected == 1'b1) && (EN == 1))
        begin
            StateMachine <= DataBits;
            ChipSel_Reg <= 0;
        end
    end

    always @(posedge SCK_Affective) begin
        if(EN == 1)
        begin
            case (StateMachine)
                Idle:   //Idle State Conditions
                begin
                end

                DataBits:
                begin
                    if(BitIndex == 16)
                    begin                        
                        StateMachine <= Idle;
                        ChipSel_Reg <= 1;
                        DataValid_Reg <= 1;
                        BitIndex <= 0;
                        Slave_RxData_Reg[15 - (BitIndex) + 1] <= MOSI;
                    end

                    else
                    begin
                        StateMachine <= DataBits;
                        ChipSel_Reg <= 0;
                        DataValid_Reg <= 0;
                        BitIndex <= BitIndex + 1;
                        MISO_Reg <= Slave_TxData[15 - (BitIndex)];
                        Slave_RxData_Reg[15 - (BitIndex) + 1] <= MOSI;
                    end
                end
            endcase
        end
    end

endmodule
