module Traffic_Light(
    RedLight, YellowLight, GreenLight,
    EN, CLK, SETCOUNTER
);
    input wire EN, CLK;
    input wire [15:0] SETCOUNTER;     
//    output wire RedLight, YellowLight, GreenLight;
    output reg RedLight, YellowLight, GreenLight;

    reg [15:0] Counter;

    initial begin
        RedLight = 0;
        YellowLight = 0;
        GreenLight = 0;

        Counter = 0;
    end

    always @(posedge CLK) 
    begin
        if(EN == 1)
        begin
            if(RedLight)
            begin                
                if(Counter == 0)
                begin
                    RedLight <= 0;
                    GreenLight <= 1;
                    Counter <= 25;
                end
            end

            else if(GreenLight)
            begin
                if(Counter == 0)
                begin
                    GreenLight <= 0;
                    YellowLight <= 1;
                    Counter <= 5;
                end
            end

            else
            begin
                if(Counter == 0)
                begin
                    YellowLight <= 0;
                    RedLight <= 1;
                    Counter <= 90;
                end
            end

            Counter <= Counter - 1;                                

        end

        else
        begin
            if(((SETCOUNTER > 30) && (SETCOUNTER < 120)) || (SETCOUNTER == 120))
            begin
                RedLight <= 1;
                YellowLight <= 0;
                GreenLight <= 0;

                Counter <= SETCOUNTER - 30;
            end

            else if(((SETCOUNTER > 5) && (SETCOUNTER < 30) || (SETCOUNTER == 30)))
            begin
                RedLight <= 0;
                YellowLight <= 0;
                GreenLight <= 1;

                Counter <= SETCOUNTER - 5;
            end

            else
            begin
                RedLight <= 0;
                YellowLight <= 1;
                GreenLight <= 0;

                Counter <= SETCOUNTER;                
            end

        end

    end
endmodule