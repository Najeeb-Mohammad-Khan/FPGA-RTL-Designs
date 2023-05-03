`timescale 1ns/10ps

module FourSSD(
    SSD_Out,SSD_Select,SSD_DP,DataIn,En,Clk
//    SSD_Out,SSD_Select,SSD_DP,En,Clk
);
    
    input wire [15:0] DataIn;
//    reg [15:0] DataIn;
    input wire Clk,En;
    input wire [3:0] SSD_DP;
    output wire [7:0] SSD_Out;
    output wire [3:0] SSD_Select;

    reg SSD_Trigger;
    reg [3:0] SSD_Select_Reg;
    reg [7:0] SSD_Out_Reg;
    reg SSD_DP_Reg;
    reg [15:0] TriggerCounter;    
//    reg [27:0] TriggerCounter;    
    reg [1:0] SSD_Select_Counter;
    reg [3:0] SingleSSD_Data;

    reg [3:0]SSD1;
    reg [3:0]SSD2;
    reg [3:0]SSD3;
    reg [3:0]SSD4;

    initial
    begin
        SSD_Trigger = 0;
        SSD_Select_Reg = 0;
        SSD_Out_Reg = 0;
        SSD_DP_Reg = 0;
        SSD_Select_Counter = 0;
        TriggerCounter = 0;
//        DataIn = 16'hABCD;
    end

    //Local Parameters for storing SSD Configuration
    localparam CommonAnode      = 0;
    localparam CommonCathode    = 1;
    localparam SSD_Type = CommonAnode;

/*
    parameter [3:0][7:0] HexToBinaryData = {{8'b011_1111}, {8'b000_0110}, {8'b101_1011}, {8'b100_1111},
                                            {8'b110_0110}, {8'b110_1101}, {8'b111_1101}, {8'b000_0111},
                                            {8'b111_1111}, {8'b110_1111}, {8'b111_0111}, {8'b111_1100},
                                            {8'b011_1001}, {8'b101_1110}, {8'b111_1001}, {8'b111_0001}};
*/


    if(SSD_Type == CommonCathode)
    begin
        assign SSD_Out = {SSD_DP_Reg,SSD_Out_Reg[6:0]};
        assign SSD_Select = SSD_Select_Reg;
    end
    
    else
    begin
        assign SSD_Out = ~{SSD_DP_Reg,SSD_Out_Reg[6:0]};
        assign SSD_Select = ~SSD_Select_Reg;
    end

//    assign SSD_DP = SSD_DP_Reg;

    // always @(*) begin
    //     SingleSSD_Data = DataIn;
    // end

    always @(*) begin
        SSD1 = DataIn[3:0];
        SSD2 = DataIn[7:4];
        SSD3 = DataIn[11:8];
        SSD4 = DataIn[15:12];
    end

    always @(SSD_Select_Counter) begin
        if(En == 1'b1)
        begin
            case (SSD_Select_Counter)
                0:
                begin
                    SingleSSD_Data = SSD1;
                    SSD_Select_Reg = 4'b0001;
                    SSD_DP_Reg = SSD_DP[0];
                end

                1:
                begin
                    SingleSSD_Data = SSD2;                    
                    SSD_Select_Reg = 4'b0010;
                    SSD_DP_Reg = SSD_DP[1];
                end

                2:
                begin
                    SingleSSD_Data = SSD3;                    
                    SSD_Select_Reg = 4'b0100;
                    SSD_DP_Reg = SSD_DP[2];
                end

                3:
                begin
                    SingleSSD_Data = SSD4;                    
                    SSD_Select_Reg = 4'b1000;
                    SSD_DP_Reg = SSD_DP[3];
                end

                default:
                begin
                    SingleSSD_Data = SSD1;
                    SSD_Select_Reg = 4'b0001;
                    SSD_DP_Reg = SSD_DP[0];
                end
            endcase
        end
        
        else
        begin
            SingleSSD_Data = SSD1;
            SSD_Select_Reg = 4'b0001;
            SSD_DP_Reg = SSD_DP[0];
        end
    end


    always @(SSD_Select_Counter) begin
        if(En == 1'b1)
        begin
           // SSD_Out_Reg = HexToBinaryData[DataIn_Reg[SSD_Select_Counter]];        

            case (SingleSSD_Data)
                4'h0:
                begin
//                    method 1:
                    //SSD_Out_Reg = 8'bZ011_1111;
//                    method 2:
                    //SSD_Out_Reg = 8'b0011_1111;
                    //or 
                    SSD_Out_Reg = 8'b011_1111;                    
                end

                4'h1:
                begin
                    SSD_Out_Reg = 8'b000_0110;                    
                end

                4'h2:
                begin
                    SSD_Out_Reg = 8'b101_1011;                    
                end

                4'h3:
                begin
                    SSD_Out_Reg = 8'b100_1111;                    
                end

                4'h4:
                begin
                    SSD_Out_Reg = 8'b110_0110;                    
                end

                4'h5:
                begin
                    SSD_Out_Reg = 8'b110_1101;                    
                end

                4'h6:
                begin
                    SSD_Out_Reg = 8'b111_1101;                    
                end

                4'h7:
                begin
                    SSD_Out_Reg = 8'b000_0111;                    
                end

                4'h8:
                begin
                    SSD_Out_Reg = 8'b111_1111;                    
                end

                4'h9:
                begin
                    SSD_Out_Reg = 8'b110_1111;                    
                end

                4'hA:
                begin
                    SSD_Out_Reg = 8'b111_0111;                    
                end

                4'hB:
                begin
                    SSD_Out_Reg = 8'b111_1100;                    
                end

                4'hC:
                begin
                    SSD_Out_Reg = 8'b011_1001;                    
                end

                4'hD:
                begin
                    SSD_Out_Reg = 8'b101_1110;                    
                end

                4'hE:
                begin
                    SSD_Out_Reg = 8'b111_1001;                    
                end

                4'hF:
                begin
                    SSD_Out_Reg = 8'b111_0001;                    
                end

                default: begin
                    SSD_Out_Reg = 8'b011_1111;
                end
            endcase
        end

        else
        begin
            SSD_Out_Reg = 0;
        end
    end

    always @(posedge SSD_Trigger) begin
        if(En == 1'b1)
        begin
            SSD_Select_Counter <= SSD_Select_Counter + 1;
        end

        else begin
            SSD_Select_Counter <= 0;
        end
    end
    
    always @(posedge Clk) begin
        if(En == 1'b1)
        begin            
            if(TriggerCounter == 50000)
//            if(TriggerCounter == 50000000)
            begin
                TriggerCounter <= 0;
                SSD_Trigger <= ~SSD_Trigger;
            end

            else begin
                TriggerCounter <= TriggerCounter + 1;            
            end
        end

        else begin
            TriggerCounter <= 0;
            SSD_Trigger <= 0;
        end
    end

endmodule