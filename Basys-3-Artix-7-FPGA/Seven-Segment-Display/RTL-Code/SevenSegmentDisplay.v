/*	
	# SevenSegmentDisplay Hexadecimal Counter #
	- Made By : Najeeb Mohammad Khan
	- Date : 2/12/22

	=> This verilog code is a state machine based common anode/cathode seven segment display 
	   hexadecimal counter.
	=> It is designed to use 100MHz clock as an input to its 'Clk' input port and use it to 
	   produce output 'SSD' which changes for every second.
	=> Ports Explained :-
		* SSD : It is 8 bit output port used to drive the seven segment display present on the FPGA board.
		      Pin Mapping -
				SSD[0] -- Seven Segment A
				SSD[1] -- Seven Segment B
				SSD[2] -- Seven Segment C
				SSD[3] -- Seven Segment D
				SSD[4] -- Seven Segment E
				SSD[5] -- Seven Segment F
				SSD[6] -- Seven Segment G
				SSD[7] -- Seven Segment DP
	        * DP : It is a 1 bit input port used to control the seven segment display's 'DP' LED using FPGA's
		       on-board switch.
		* En : It is a 1 bit input port used as master enable pin for the whole circuit, controlled via
		       FPGA's on-board switch.
		* Clk : It is a 1-bit input port used feed master clock (100MHz) as an input to the circuit. 
			This clock is internally divided to provide a 1 Hz Clock for state machine functioning.
 
*/

//TimeScale :: 1ns with 1ps precision
`timescale 1ns / 1ps

module SevenSegmentDisplay(
    SSD,DP,En,Clk
);
    //Port Declarations
    input wire En,DP,Clk;
    output wire [7:0]SSD;

    //Registers Declared
    reg [26:0] Clk_Counter;
    reg  SlowClk_Reg;
    wire SlowClk;

    //Local Parameters for storing SSD Configuration
    localparam CommonAnode      = 0;
    localparam CommonCathode    = 1;
    localparam SSD_Type = CommonAnode;

    /* Symbols Table
    0 = 8'b011_1111;        8 = 8'b111_1111;
    1 = 8'b000_0110;        9 = 8'b110_1111;                
    2 = 8'b101_1011;        A = 8'b111_0111;
    3 = 8'b100_1111;        B = 8'b111_1100;
    4 = 8'b110_0110;        C = 8'b011_1001;
    5 = 8'b110_1101;        D = 8'b101_1110;
    6 = 8'b111_1101;        E = 8'b111_1001;
    7 = 8'b000_0111;        F = 8'b111_0001;
    */

    //Local Params for storing the States
    localparam Zero      = 4'b0000;
    localparam One       = 4'b0001;
    localparam Two       = 4'b0010;
    localparam Three     = 4'b0011;
    localparam Four      = 4'b0100;
    localparam Five      = 4'b0101;
    localparam Six       = 4'b0110;
    localparam Seven     = 4'b0111;
    localparam Eight     = 4'b1000;
    localparam Nine      = 4'b1001;
    localparam LetterA   = 4'b1010;
    localparam LetterB   = 4'b1011;
    localparam LetterC   = 4'b1100;
    localparam LetterD   = 4'b1101;
    localparam LetterE   = 4'b1110;
    localparam LetterF   = 4'b1111;

    //Declaring the states 
    reg [3:0] PresentState, NextState;
    reg [6:0] InterSSD;

    //Initial Block
    initial begin
        PresentState = Zero;  
        Clk_Counter = 0;
        SlowClk_Reg = 0;                 
    end

    //Always Block for State Machine Definitions
    always @(PresentState, En) begin
        //Default Conditions
        InterSSD = 1'b0;
        
        //Case for StateMachine Definitions
        case (PresentState)
            Zero:
            begin
                if(En == 1'b1)
                begin
                    NextState = One;
                    InterSSD = 8'b011_1111;                    
                end
                else begin
                    NextState = Zero;
                    InterSSD = 8'b011_1111;                    
                end
            end

            One:
            begin
                if(En == 1'b1)
                begin
                    NextState = Two;
                    InterSSD = 8'b000_0110;                    
                end
                else begin
                    NextState = Zero;
                    InterSSD = 8'b011_1111;                    
                end
            end

            Two:
            begin
                if(En == 1'b1)
                begin
                    NextState = Three;
                    InterSSD = 8'b101_1011;                    
                end
                else begin
                    NextState = Zero;
                    InterSSD = 8'b011_1111;                    
                end
            end

            Three:
            begin
                if(En == 1'b1)
                begin
                    NextState = Four;
                    InterSSD = 8'b100_1111;                     
                end
                else begin
                    NextState = Zero;
                    InterSSD = 8'b011_1111;                    
                end
            end

            Four:
            begin
                if(En == 1'b1)
                begin
                    NextState = Five;
                    InterSSD = 8'b110_0110;                    
                end
                else begin
                    NextState = Zero;
                    InterSSD = 8'b011_1111;                    
                end
            end

            Five:
            begin
                if(En == 1'b1)
                begin
                    NextState = Six;
                    InterSSD = 8'b110_1101;                    
                end
                else begin
                    NextState = Zero;
                    InterSSD = 8'b011_1111;                    
                end
            end

            Six:
            begin
                if(En == 1'b1)
                begin
                    NextState = Seven;
                    InterSSD = 8'b111_1101;                    
                end
                else begin
                    NextState = Zero;
                    InterSSD = 8'b011_1111;                    
                end
            end

            Seven:
            begin
                if(En == 1'b1)
                begin
                    NextState = Eight;
                    InterSSD = 8'b000_0111;                    
                end
                else begin
                    NextState = Zero;
                    InterSSD = 8'b011_1111;                    
                end
            end

            Eight:
            begin
                if(En == 1'b1)
                begin
                    NextState = Nine;
                    InterSSD = 8'b111_1111;                    
                end
                else begin
                    NextState = Zero;
                    InterSSD = 8'b011_1111;                    
                end
            end

            Nine:
            begin
                if(En == 1'b1)
                begin
                    NextState = LetterA;
                    InterSSD = 8'b110_1111;                    
                end
                else begin
                    NextState = Zero;
                    InterSSD = 8'b011_1111;                    
                end
            end

            LetterA:
            begin
                if(En == 1'b1)
                begin
                    NextState = LetterB;
                    InterSSD = 8'b111_0111;                    
                end
                else begin
                    NextState = Zero;
                    InterSSD = 8'b011_1111;                    
                end
            end

            LetterB:
            begin
                if(En == 1'b1)
                begin
                    NextState = LetterC;
                    InterSSD = 8'b111_1100;                    
                end
                else begin
                    NextState = Zero;
                    InterSSD = 8'b011_1111;                    
                end
            end

            LetterC:
            begin
                if(En == 1'b1)
                begin
                    NextState = LetterD;
                    InterSSD = 8'b011_1001;                    
                end
                else begin
                    NextState = Zero;
                    InterSSD = 8'b011_1111;                    
                end
            end

            LetterD:
            begin
                if(En == 1'b1)
                begin
                    NextState = LetterE;
                    InterSSD = 8'b101_1110;                    
                end
                else begin
                    NextState = Zero;
                    InterSSD = 8'b011_1111;                    
                end
            end

            LetterE:
            begin
                if(En == 1'b1)
                begin
                    NextState = LetterF;
                    InterSSD = 8'b111_1001;                    
                end
                else begin
                    NextState = Zero;
                    InterSSD = 8'b011_1111;                    
                end
            end

            LetterF:
            begin
                if(En == 1'b1)
                begin
                    NextState = Zero;
                    InterSSD = 8'b111_0001;                    
                end
                else begin
                    NextState = Zero;
                    InterSSD = 8'b011_1111;                    
                end
            end
        endcase
    end

    if(SSD_Type == CommonCathode)
    begin
        assign SSD = {DP,InterSSD};    
    end
    
    else
    begin
        assign SSD = ~{DP,InterSSD};            
    end

    //Non-Blocking Assignment of PresentState with NextState
    always @(posedge SlowClk) begin
        PresentState <= NextState;
    end

    assign SlowClk = SlowClk_Reg;

    //Clock Frequency Divider for converting 100MHz to 1Hz
    always @(posedge Clk) begin
        if(En == 1'b1)
        begin
            if(Clk_Counter == (100000000/2) - 1)
            begin
                SlowClk_Reg <= ~ SlowClk_Reg;
                Clk_Counter <= 0;
            end

            else begin
                Clk_Counter <= Clk_Counter + 1;                
            end
        end

        else begin
            SlowClk_Reg = 0;
            Clk_Counter <= 0;
        end
    end


endmodule