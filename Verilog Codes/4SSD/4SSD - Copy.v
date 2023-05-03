module 4SSD(
    SSD_Out,SSD_DP,SSD_Select,DataIn,En,Clk
);
    
    input wire [15:0]DataIn;
    input wire En,Clk;
    output wire [7:0]SSD_Out;
    output wire [2:0]SSD_DP;
    output wire [1:0]SSD_Select;

    reg SSD_Trigger;
    reg SSD_Select_Reg;
    reg SSD_Out_Reg;
    reg SSD_DP_Reg;
    reg [15:0] TriggerCounter;    
    reg [1:0]SSD_Select_Counter;
    reg DataIn_Reg;

    initial
    begin
        SSD_Trigger = 0;
        SSD_Select_Reg = 0;
        SSD_Out_Reg = 0;
        SSD_DP_Reg = 0;
        TriggerCounter = 0;
    end

    parameter [3:0][7:0] HexToBinaryData = {{8'b011_1111}, {8'b000_0110}, {8'b101_1011}, {8'b100_1111},
                                            {8'b110_0110}, {8'b110_1101}, {8'b111_1101}, {8'b000_0111},
                                            {8'b111_1111}, {8'b110_1111}, {8'b111_0111}, {8'b111_1100},
                                            {8'b011_1001}, {8'b101_1110}, {8'b111_1001}, {8'b111_0001}};
    
    assign SSD_Select = SSD_Select_Reg;
    assign SSD_Out = SSD_Out_Reg;
    assign SSD_DP = SSD_DP_Reg;



    always(posedge SSD_Trigger) begin
        if(En == 1'b1)
        begin
            SSD_Out_Reg = HexToBinaryData(DataIn_Reg(SSD_Select_Counter));        
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
            begin
                TriggerCounter <= 0;
                SSD_Trigger <= ~SSD_Trigger;
            end

            else begin
                TriggerCounter <= TriggerCounter + TriggerCounter;            
            end
        end

        else begin
            TriggerCounter <= 0;
            SSD_Trigger <= 0;
        end
    end

endmodule