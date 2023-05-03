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
`include "EightBit_LED.v"

module NandLandUART_RX #(
    parameter ClocksPerBit = 10417   
) (
    LEDOut, RxDataOut,Clk, Rx, En
);
    
    input Clk;
    input Rx;
    input En;
//    output [7:0] RxDataOut;
    output [7:0] LEDOut;
    output [7:0] RxDataOut;

    //State Machines Parameters
    parameter Idle      = 3'b000;
    parameter StartBit     = 3'b001;
    parameter DataBits      = 3'b010;
    parameter StopBit      = 3'b011;
    parameter CleanUp   = 3'b100;

    reg [13:0] ClockCounter = 0;
    reg [2:0] BitIndex = 0;
    reg [7:0] Rx_Byte = 0;
    reg Rx_DataValid = 0;
    reg [2:0] StateMachine = 0;

//    assign RxDataOut = Rx_Byte;

    EightBit_LED uut2(LEDOut, Rx_Byte, En, Clk);
    
    assign RxDataOut = Rx_Byte;

    //The Rx State Machine
    always @(posedge Clk) begin
        case (StateMachine)
            Idle:   //Idle State Conditions
            begin
                //Initializing parameters for IDLE condition
                ClockCounter <= 0;
                BitIndex <= 0;
                Rx_DataValid <= 0;

                //If we sense Rx to be 0, activate the state machine
                if(Rx == 0)
                begin
                    StateMachine <= StartBit;
                end
                else    //Stay in idle state as Rx show no 0 value
                begin
                    StateMachine <= Idle;
                end
            end


            StartBit:   //StartBit conditions
            begin
                //Inside the Start Bit Condition, stay till the middle of the start bit.
                if(ClockCounter == (ClocksPerBit - 1)/2)    //We have reached the middle of the StartBit
                begin
                    if(Rx == 0)
                    begin
                        ClockCounter <= 0;
                        StateMachine <= DataBits;
                    end

                    else
                    begin
                        StateMachine <= Idle;
                    end
                end

                else begin  //We have not reached the middle of the Start Bit
                    ClockCounter <= ClockCounter + 1;
                    StateMachine <= StartBit;
                end
            end

            DataBits:   //Data Bit conditions
            begin
                //Inside the Data Bit Condition, stay till the middle of the Data Bit.
                if(ClockCounter < (ClocksPerBit - 1))
                begin
                    ClockCounter <= ClockCounter + 1;
                    StateMachine <= DataBits;
                end

                else begin  //We are at the middle of the Data Bit
                    ClockCounter <= 0;

                    //Receive the data
                    Rx_Byte[BitIndex] <= Rx;

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
                //Inside the Stop Bit Condition, stay till the middle of the Stop Bit.
                if(ClockCounter < (ClocksPerBit - 1))   //We have not reached the middle of the Stop Bit
                begin
                    ClockCounter <= ClockCounter + 1;
                    StateMachine <= StopBit;
                end

                else begin  //We have reached the middle of the Stop Bit
                    Rx_DataValid <= 1;
                    ClockCounter <= 0;
                    StateMachine <= CleanUp;
                end
            end

            CleanUp:    //Clean Up State Machine condions
            begin
                StateMachine <= Idle;
                Rx_DataValid <= 0;
            end

            //Set Default condition to have StateMachine at Idle condition
            default: begin
                StateMachine <= Idle;
            end
        endcase

    end


endmodule