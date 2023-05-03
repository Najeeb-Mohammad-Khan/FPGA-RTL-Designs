module TwoDigit_DecimalCounter(
    CountOut,En,Clk
);
    input wire En;
    input wire Clk;
    output wire [7:0] CountOut;

    reg [3:0] Counter_OnesPlace;
    reg [3:0] Counter_TensPlace;

    initial begin
        Counter_OnesPlace = 0;
        Counter_TensPlace = 0;
    end

    assign CountOut = {Counter_TensPlace, Counter_OnesPlace};

    always @(posedge Clk) begin
        if(En == 1)
        begin
            if(Counter_OnesPlace < 9) begin
                Counter_OnesPlace <= Counter_OnesPlace + 1;
            end

            else begin
                Counter_OnesPlace = 0;

                if(Counter_TensPlace < 9)
                begin
                    Counter_TensPlace <= Counter_TensPlace + 1;    
                end

                else begin
                    Counter_TensPlace <= 0;
                end
            end
        end

        else begin
            Counter_TensPlace <= 0;
            Counter_OnesPlace <= 0;
        end
    end

endmodule