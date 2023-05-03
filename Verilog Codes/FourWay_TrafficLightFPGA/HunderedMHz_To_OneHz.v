module HunderedMHz_To_OneHz(
    Clk_Out, Clk_In, En
);
    output wire Clk_Out;
    input wire Clk_In, En;

    reg SlowClk_Reg;
    reg [26:0] Clk_Counter;

    assign Clk_Out = SlowClk_Reg;

    always @(posedge Clk_In) begin
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
            SlowClk_Reg <= 0;
            Clk_Counter <= 0;
        end
    end

endmodule
