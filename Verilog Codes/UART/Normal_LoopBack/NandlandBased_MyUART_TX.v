/*
    Parameter ClocksPerBit = (Freq of Input Clock/Baurd Rate of Uart)
    In our case :
                For 115200 Baud Rate:
                    ClocksPerBit = 100MHz / 115200
                                 = 100_000_000 / 115_200
                                 = 868.05556
                                 ~ 868

                For 9600 Baud Rate:
                    ClocksPerBit = 100MHz / 9600
                                 = 100_000_000 / 9_600
                                 = 10416.66667
                                 ~ 10417
*/

`timescale 1ns / 1ps

`include "RisingEdgeDetector.v"

module  NandlandBased_MyUART_TX #(
    parameter ClocksPerBit = 10417   
) (
    Tx_Data, TxDone, Tx_DataValid, Clk, Tx
);

    input wire Clk;
//    inout wire SendTxData;
    input wire [7:0] Tx_Data;
    input wire Tx_DataValid;
    output wire Tx, TxDone;
//    output wire [7:0] TxDataOut;

    //State Machines Parameters
    parameter Idle       = 3'b000;
    parameter StartBit   = 3'b001;
    parameter DataBits   = 3'b010;
    parameter StopBit    = 3'b011;
    parameter CleanUp    = 3'b100;

    reg [13:0] ClockCounter = 0;
    reg [2:0] BitIndex = 0;
    reg [7:0] Tx_Byte;
    reg [2:0] StateMachine = 0;
    reg TxDone_Reg, Tx_Reg;
//    reg TxDataValid_Flag;
    wire RiseEdgeDectected;

//    assign TxDataOut = Tx_Byte;
    assign TxDone = TxDone_Reg;
    assign Tx = Tx_Reg;

    RisingEdgeDetector uut (RiseEdgeDectected, Tx_DataValid, 1'b1, Clk);

    initial begin
//        Tx_Byte = 8'h61;
        TxDone_Reg = 0;
        Tx_Reg = 1;
//        TxDataValid_Flag = 0;
//        SendTxData = 1'b0;
    end

    // always @(posedge RiseEdgeDectected) begin
    //         TxDataValid_Flag <= 1;        
    // end

    // Tri State Buffer for Tx_Data assignment
//    assign Tx_Data = TxDone_Reg ? 0 : 1'bZ;

    //The Tx State Machine
    always @(posedge Clk) begin
        case (StateMachine)
            Idle:   //Idle State Conditions
            begin
                BitIndex <= 0;

                if(RiseEdgeDectected == 0)
                begin
                    StateMachine <= Idle;
                    TxDone_Reg <= 0;
                end

                else begin
                    StateMachine <= StartBit;
                end
            end

            StartBit:   //Data Bit conditions
            begin
                //Inside the Data Bit Condition, stay till the end of the start Bit.
                if(ClockCounter < (ClocksPerBit - 1))
                begin
                    ClockCounter <= ClockCounter + 1;
                    StateMachine <= StartBit;
                end

                else begin  //We are at the middle of the Data Bit
                    ClockCounter <= 0;
                    Tx_Reg <= 0;
                    StateMachine <= DataBits;
                end
            end

            DataBits:   //StartBit conditions
            begin
                //Inside the Data Bit Condition, stay till the end of the Data Bit.
                if(ClockCounter < (ClocksPerBit - 1))
                begin
                    ClockCounter <= ClockCounter + 1;
                    StateMachine <= DataBits;
                end

                else begin  //We are at the middle of the Data Bit
                    ClockCounter <= 0;

                    //Receive the data
                    Tx_Reg <= Tx_Data[BitIndex];

                    //Check whether we have received all bits
                    if(BitIndex < 7)    //No we have not received all bits
                    begin
                        StateMachine <= DataBits;
                        BitIndex <= BitIndex + 1;
                    end

                    else begin  //We have recieved all the bits
                        StateMachine <= StopBit;
                        BitIndex <= 0;
                    end
                end                
                
            end

            StopBit: //StopBit Conditions
            begin
                //Inside the Stop Bit Condition, stay till the the completion of Stop Bit.
                if(ClockCounter < (ClocksPerBit - 1))   //We have not reached the end of the Stop Bit
                begin
                    ClockCounter <= ClockCounter + 1;
                    StateMachine <= StopBit;
                end

                else begin  //We have reached the middle of the Stop Bit
                    Tx_Reg <= 1;
                    ClockCounter <= 0;
                    StateMachine <= CleanUp;
                    TxDone_Reg <= 1;
//                    TxDataValid_Flag <= 0;
                end
            end

            CleanUp:    //Clean Up State Machine condions
            begin
                StateMachine <= Idle;
//                Rx_DataValid <= 0;
//                SendTxData <= 1'bZ;
            end

            //Set Default condition to have StateMachine at Idle condition
            default: begin
                StateMachine <= Idle;
            end
        endcase

    end
endmodule