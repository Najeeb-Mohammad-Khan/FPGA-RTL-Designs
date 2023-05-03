//`include "TrafficJunctionLight.v"

module TrafficJunctionLight_tb;
    wire t_N_RedLight, t_N_YellowLight, t_N_GreenLight;
    wire t_E_RedLight, t_E_YellowLight, t_E_GreenLight;
    wire t_S_RedLight, t_S_YellowLight, t_S_GreenLight;
    wire t_W_RedLight, t_W_YellowLight, t_W_GreenLight;
    reg t_EN, t_CLK;
//    reg [15:0] t_SETCOUNTER;

    TrafficJunctionLight TL1(
                      .N_RedLight(t_N_RedLight), 
                      .N_YellowLight(t_N_YellowLight),
                      .N_GreenLight(t_N_GreenLight),

                      .E_RedLight(t_E_RedLight), 
                      .E_YellowLight(t_E_YellowLight),
                      .E_GreenLight(t_E_GreenLight),

                      .S_RedLight(t_S_RedLight), 
                      .S_YellowLight(t_S_YellowLight),
                      .S_GreenLight(t_S_GreenLight),

                      .W_RedLight(t_W_RedLight), 
                      .W_YellowLight(t_W_YellowLight),
                      .W_GreenLight(t_W_GreenLight),

                      .EN(t_EN),
                      .CLK(t_CLK)
                        );

    initial 
        begin
            t_EN = 0;
            t_CLK = 0;
            #20;
            t_EN = 1;
            #3000;
//	    #90;
            // t_EN = 0;
            // #1;
            $finish;
        end

    initial
        begin
            forever                 
                begin        
                    #10;
                    t_CLK = ~t_CLK;
                end
        end

    initial begin
        $dumpfile("TrafficJunctionLight_tb.vcd");
	    $dumpvars(0,TrafficJunctionLight_tb);
        $display("Started Data Dump");
    end

endmodule