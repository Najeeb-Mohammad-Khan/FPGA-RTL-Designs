`timescale 1ns / 10ps
/*
ClockPerBit = (100MHz / 400KHz) = 250
*/

module I2C_Master#(
//    parameter ClocksPerBit = 250   
      parameter BitRate_Kbps = 400
)(
    SDA, SCL, SlaveAddr, Read_WriteBar, WriteData, ReadData, StartFlag, DoneFlag, EN, CLK_IN
    );

    output wire [7:0] ReadData;
    input wire [7:0] WriteData;
    input wire EN;
    input wire Read_WriteBar;
    input wire CLK_IN;
    input wire [6:0] SlaveAddr;
    inout wire SDA;
    output wire SCL;
    output wire DoneFlag;
    input wire StartFlag;


    reg [2:0] StateMachine = 0;
    reg [3:0] BitIndex;
    reg [7:0] ReadData_Reg;
    reg DoneFlag_Reg;
//    reg Internal_Clk;

    //State Machines Parameters
    parameter Idle           = 3'b000;
    parameter StartBit       = 3'b001;
    parameter AddressBits    = 3'b010;
    parameter Read_WriteBarBit  = 3'b011;
    parameter AddrACKBit     = 3'b100;
    parameter DataBits       = 3'b101;
    parameter DataACKBits    = 3'b110;
    parameter StopBit        = 3'b111;
    // parameter CleanUp        = 3'b111;

    parameter ClocksPerBit = (100_000_000 / (BitRate_Kbps * 1000));

    // parameter SCL_PulseHighWidth = (ClocksPerBit / 5);
    // parameter SCL_PulseLowWidth  = ((ClocksPerBit * 4) / 5);

    parameter SCL_PulseHighWidth = (ClocksPerBit / 2);
    parameter SCL_PulseLowWidth  = (ClocksPerBit / 2);

    reg SCL_Reg;
    reg SDA_Reg;

    reg [13:0] ClockCounter;
    reg GetSlaveACK;
    reg Received_ACK_Bit;
    // reg Run_I2C;

    wire StartFlag_RiseEdgeDectected;

    initial begin
        SCL_Reg = 1;
        SDA_Reg = 1;
        ClockCounter = 0;
        BitIndex = 0;
        GetSlaveACK = 0;
        Received_ACK_Bit = 0;
//        Internal_Clk = 0;
        ReadData_Reg = 0;
        DoneFlag_Reg = 0;
        // Run_I2C = 0;
    end

    assign ReadData = ReadData_Reg;
    assign SCL = SCL_Reg;
    assign DoneFlag = DoneFlag_Reg;
//    assign SDA = SDA_Reg;

    assign SDA = GetSlaveACK ? 1'bZ : SDA_Reg ;

    RisingEdgeDetector uut (StartFlag_RiseEdgeDectected, StartFlag, EN, CLK_IN);

    // always @(posedge StartFlag_RiseEdgeDectected) begin
    //     if(EN == 1'b1)
    //     begin
    //         Run_I2C <= 1;                     
    //     end

    //     else begin
    //         Run_I2C <= 0;
    //     end
    // end

    always @(posedge CLK_IN) begin
        if(EN == 1'b1)
        begin
            case (StateMachine)
                Idle:
                begin
                    // if(Run_I2C == 1'b1)begin
                    if((StartFlag_RiseEdgeDectected == 1'b1) && (EN == 1))
                    begin
                        StateMachine <= StartBit; 
                        // Run_I2C <= 0;                   
                    end

                    else begin
                        StateMachine <= Idle;                                            
                    end

                    SCL_Reg <= 1;
                    SDA_Reg <= 1;
                    ClockCounter <= 0;
                    DoneFlag_Reg <= 0;
                end

                StartBit:
                begin
                    //Inside the Start Bit Condition, stay till the middle of the start bit.
                    if(ClockCounter < (SCL_PulseLowWidth - 1)/2)    //We have reached the middle of the StartBit
                    begin
                        ClockCounter <= ClockCounter + 1;
                        StateMachine <= StartBit;
                        SCL_Reg <= 1;
                        SDA_Reg <= 0;
                    end

                    else begin  //We have not reached the middle of the Start Bit
                        if (ClockCounter == (SCL_PulseLowWidth - 1))
                        begin
                            ClockCounter <= 0;
                            StateMachine <= AddressBits;
                            SCL_Reg <= 0;
                            SDA_Reg <= 0;                            
                        end

                        else
                        begin                            
                            ClockCounter <= ClockCounter + 1;
                            StateMachine <= StartBit;
                            SCL_Reg <= 0;
                            SDA_Reg <= 0;
                        end
                    end
                end

                AddressBits:
                begin                    
                     if(BitIndex == (7))    //7 as we need 7 AddrBits to send via SDA. Minus 1 as we dont want BitIndex Equal to 7 as at this BitIndex, SlaveAddr dont exist.
                     begin
                        BitIndex <= 0;
                        StateMachine <= Read_WriteBarBit;
                        SDA_Reg <= Read_WriteBar;
                        //GetSlaveACK <= 1;
                        SCL_Reg <= 0;

                     end

                     else begin                        
                         //Inside the Start Bit Condition, stay till the middle of the start bit.
                         if(ClockCounter == (SCL_PulseLowWidth - 1)/2)    //We have reached the middle of the StartBit
                         begin
                            ClockCounter <= ClockCounter + 1;
                            StateMachine <= AddressBits;
                            SDA_Reg <= SlaveAddr[6 - BitIndex];
                            SCL_Reg <= 1;
                         end

                         else if(ClockCounter == ((SCL_PulseLowWidth - 1)/2) + (SCL_PulseHighWidth - 1))
                         begin
                            ClockCounter <= ClockCounter + 1;
                            StateMachine <= AddressBits;
                            SDA_Reg <= SlaveAddr[6 - BitIndex];
                            SCL_Reg <= 0;
                         end

                         else if(ClockCounter == ((SCL_PulseLowWidth - 1)) + (SCL_PulseHighWidth - 1))
                         begin
                            ClockCounter <= 0;
                            StateMachine <= AddressBits;
                            BitIndex = BitIndex + 1;

                            if(BitIndex < 6)
                            begin
                                SDA_Reg <= SlaveAddr[6 - BitIndex];                                                                            
                            end

                            else begin
                                SDA_Reg <= SlaveAddr[0];                                            
                            end

                            SCL_Reg <= 0;
                         end

                         else begin  //We have not reached the middle of the Start Bit
                             ClockCounter <= ClockCounter + 1;
                             StateMachine <= AddressBits;

                            SDA_Reg <= SlaveAddr[6 - BitIndex];                                                                            

                             //SCL_Reg <= 0;
                         end
                     end
                end

                Read_WriteBarBit :
                begin
                    if (ClockCounter == ((SCL_PulseLowWidth - 1)/2))
                    begin
                        ClockCounter <= ClockCounter + 1;
                        StateMachine <= Read_WriteBarBit;
                        SDA_Reg <= Read_WriteBar;
                        SCL_Reg <= 1;
                        
                    end

                    else if(ClockCounter == ((SCL_PulseLowWidth - 1)/2) + (SCL_PulseHighWidth - 1))
                    begin
                       ClockCounter <= ClockCounter + 1;
                       StateMachine <= Read_WriteBarBit;
                       SDA_Reg <= Read_WriteBar;
                       SCL_Reg <= 0;
                    end

                    else if (ClockCounter == ((SCL_PulseLowWidth - 1)+ (SCL_PulseHighWidth - 1)))
                    begin
                        // ClockCounter <= 0;
                        // StateMachine <= DataBits;
                        // SCL_Reg <= 0;
                        // GetSlaveACK <= 0;
                        // //SDA_Reg <= 1'bZ;       

                        // BitIndex <= 0;
                        ClockCounter <= 0;
                        StateMachine <= AddrACKBit;
                        SDA_Reg <= 1'bZ;
                        GetSlaveACK <= 1;
                        SCL_Reg <= 0;
            
                    end
                    
                    else
                    begin                            
                        ClockCounter <= ClockCounter + 1;
                        StateMachine <= Read_WriteBarBit;
                        //SCL_Reg <= 0;
                        
                        SDA_Reg <= Read_WriteBar;
                    end                                        
                end

                AddrACKBit:
                begin
                    if (ClockCounter == ((SCL_PulseLowWidth - 1)/2))
                    begin
                        ClockCounter <= ClockCounter + 1;
                        StateMachine <= AddrACKBit;
                        SCL_Reg <= 1;
                        Received_ACK_Bit <= SDA;
                    end

                    else if(ClockCounter == ((SCL_PulseLowWidth - 1)/2) + (SCL_PulseHighWidth - 1))
                    begin
                       ClockCounter <= ClockCounter + 1;
                       StateMachine <= AddrACKBit;
                       SCL_Reg <= 0;
                    end

                    else if (ClockCounter == ((SCL_PulseLowWidth - 1)+ (SCL_PulseHighWidth - 1)))
                    begin
                        ClockCounter <= 0;
                        StateMachine <= DataBits;
                        SCL_Reg <= 0;
                        GetSlaveACK <= 0;
                        //SDA_Reg <= 1'bZ;                   
                    end
                    
                    else
                    begin                            
                        ClockCounter <= ClockCounter + 1;
                        StateMachine <= AddrACKBit;
                        //SCL_Reg <= 0;
                        
                        //SDA_Reg <= 1'bZ;
                    end                    
                end

                DataBits:
                begin
                    if(Received_ACK_Bit == 0)
                    begin
                        if(Read_WriteBar == 1)  // Read Operation on Slave
                        begin
                            if(BitIndex == (8))    //7 as we need 7 AddrBits to send via SDA. Minus 1 as we dont want BitIndex Equal to 7 as at this BitIndex, SlaveAddr dont exist.
                            begin
                                BitIndex <= 0;
                                StateMachine <= DataACKBits;
                                SDA_Reg <= 1'bZ;
                                GetSlaveACK <= 0;
                                SCL_Reg <= 0;

                            end

                            else 
                            begin                           
                                //Inside the Start Bit Condition, stay till the middle of the start bit.
                                if(ClockCounter == (SCL_PulseLowWidth - 1)/2)    //We have reached the middle of the StartBit
                                begin
                                    ClockCounter <= ClockCounter + 1;
                                    StateMachine <= DataBits;
                                    ReadData_Reg[7 - BitIndex] <= SDA;
                                    SCL_Reg <= 1;
                                end

                                else if(ClockCounter == ((SCL_PulseLowWidth - 1)/2) + (SCL_PulseHighWidth - 1))
                                begin
                                    ClockCounter <= ClockCounter + 1;
                                    StateMachine <= DataBits;
                                    ReadData_Reg[7 - BitIndex] <= SDA;
                                    SCL_Reg <= 0;
                                end

                                else if(ClockCounter == ((SCL_PulseLowWidth - 1)) + (SCL_PulseHighWidth - 1))
                                begin
                                    ClockCounter <= 0;
                                    StateMachine <= DataBits;
                                    BitIndex = BitIndex + 1;

                                    if(BitIndex < 7)
                                    begin
                                        ReadData_Reg[7 - BitIndex] <= SDA;
                                    end

                                    else begin
                                        ReadData_Reg[7 - BitIndex] <= SDA;
                                    end

                                    SCL_Reg <= 0;
                                end

                                else begin  //We have not reached the middle of the Start Bit
                                    ClockCounter <= ClockCounter + 1;
                                    StateMachine <= DataBits;

                                    ReadData_Reg[7 - BitIndex] <= SDA;

                                    //SCL_Reg <= 0;
                                end
                            end
                        end                            
                    

                        else 
                        begin      // Write Operation on Slave
                            if(BitIndex == (8))    //7 as we need 7 AddrBits to send via SDA. Minus 1 as we dont want BitIndex Equal to 7 as at this BitIndex, SlaveAddr dont exist.
                            begin
                                BitIndex <= 0;
                                StateMachine <= DataACKBits;
                                SDA_Reg <= 1'bZ;
                                GetSlaveACK <= 1;
                                SCL_Reg <= 0;

                            end

                            else 
                            begin                        
                                //Inside the Start Bit Condition, stay till the middle of the start bit.
                                if(ClockCounter == (SCL_PulseLowWidth - 1)/2)    //We have reached the middle of the StartBit
                                begin
                                    ClockCounter <= ClockCounter + 1;
                                    StateMachine <= DataBits;
                                    SDA_Reg <= WriteData[7 - BitIndex];
                                    SCL_Reg <= 1;
                                end

                                else if(ClockCounter == ((SCL_PulseLowWidth - 1)/2) + (SCL_PulseHighWidth - 1))
                                begin
                                    ClockCounter <= ClockCounter + 1;
                                    StateMachine <= DataBits;
                                    SDA_Reg <= WriteData[7 - BitIndex];
                                    SCL_Reg <= 0;
                                end

                                else if(ClockCounter == ((SCL_PulseLowWidth - 1)) + (SCL_PulseHighWidth - 1))
                                begin
                                    ClockCounter <= 0;
                                    StateMachine <= DataBits;
                                    BitIndex = BitIndex + 1;

                                    if(BitIndex < 7)
                                    begin
                                        SDA_Reg <= WriteData[7 - BitIndex];                                                                            
                                    end

                                    else 
                                    begin
                                        SDA_Reg <= WriteData[0];                                            
                                    end

                                    SCL_Reg <= 0;
                                end

                                else 
                                begin  //We have not reached the middle of the Start Bit
                                    ClockCounter <= ClockCounter + 1;
                                    StateMachine <= DataBits;

                                    SDA_Reg <= WriteData[7 - BitIndex];                                                                            

                                    //SCL_Reg <= 0;
                                end
                            end
                        end
                    end
                    
                    else begin
                        StateMachine <= StopBit;                        
                    end
                end

                DataACKBits:
                begin
                    if(Read_WriteBar == 0)
                    begin
                        if (ClockCounter == ((SCL_PulseLowWidth - 1)/2))
                        begin
                            ClockCounter <= ClockCounter + 1;
                            StateMachine <= DataACKBits;
                            SCL_Reg <= 1;
                            Received_ACK_Bit <= SDA;
                        end

                        else if(ClockCounter == ((SCL_PulseLowWidth - 1)/2) + (SCL_PulseHighWidth - 1))
                        begin
                        ClockCounter <= ClockCounter + 1;
                        StateMachine <= DataACKBits;
                        SCL_Reg <= 0;
                        end

                        else if (ClockCounter == ((SCL_PulseLowWidth - 1)+ (SCL_PulseHighWidth - 1)))
                        begin
                            ClockCounter <= 0;
                            StateMachine <= StopBit;
                            SCL_Reg <= 0;
                            GetSlaveACK <= 0;
                            SDA_Reg <= 0;                   
                        end
                        
                        else
                        begin                            
                            ClockCounter <= ClockCounter + 1;
                            StateMachine <= DataACKBits;
                            //SCL_Reg <= 0;
                            
                            //SDA_Reg <= 1'bZ;
                        end                    
                    end

                    else begin
                        if (ClockCounter == ((SCL_PulseLowWidth - 1)/2))
                        begin
                            ClockCounter <= ClockCounter + 1;
                            StateMachine <= DataACKBits;
                            SCL_Reg <= 1;
                            //SDA_Reg <= 1;
                        end

                        else if(ClockCounter == ((SCL_PulseLowWidth - 1)/2) + (SCL_PulseHighWidth - 1))
                        begin
                        ClockCounter <= ClockCounter + 1;
                        StateMachine <= DataACKBits;
                        SCL_Reg <= 0;
                        //SDA_Reg <= 0;
                        end

                        else if (ClockCounter == ((SCL_PulseLowWidth - 1)+ (SCL_PulseHighWidth - 1)))
                        begin
                            ClockCounter <= 0;
                            StateMachine <= StopBit;
                            SCL_Reg <= 0;
                            SDA_Reg <= 0;                   
                        end
                        
                        else
                        begin                            
                            ClockCounter <= ClockCounter + 1;
                            StateMachine <= DataACKBits;
                            //SCL_Reg <= 0;
                            
                            SDA_Reg <= 1;
                        end                                            
                    end
                end

                StopBit:
                begin
                    if (ClockCounter == ((SCL_PulseLowWidth - 1)/2))
                    begin
                        ClockCounter <= ClockCounter + 1;
                        StateMachine <= StopBit;
                        SCL_Reg <= 1;
                        SDA_Reg <= 0;
                    end

                    else if(ClockCounter == ((SCL_PulseLowWidth - 1)/2) + (SCL_PulseHighWidth - 1))
                    begin
                       ClockCounter <= ClockCounter + 1;
                       StateMachine <= Idle;
                       SCL_Reg <= 1;
                       SDA_Reg <= 1;
                       DoneFlag_Reg <= 1;
                    end

                    // else if (ClockCounter == ((SCL_PulseLowWidth - 1)+ (SCL_PulseHighWidth - 1)))
                    // begin
                    //     ClockCounter <= 0;
                    //     StateMachine <= StopBit;
                    //     SCL_Reg <= 0;
                    //     //SDA_Reg <= 1'bZ;                   
                    // end
                    
                    else
                    begin                            
                        ClockCounter <= ClockCounter + 1;
                        StateMachine <= StopBit;
                        //SCL_Reg <= 0;
                        
                        //SDA_Reg <= 0;
                    end                                        
                end

                // CleanUp:
                // begin
                //     StateMachine <= Idle;
                    
                // end

                default: begin
                    StateMachine <= Idle;
                end
            endcase
        end

        else begin
            StateMachine <= Idle;            
        end
    end


endmodule
