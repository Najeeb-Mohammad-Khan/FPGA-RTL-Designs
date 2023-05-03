`include "Traffic_Light.v"
`include "HunderedMHz_To_OneHz.v"

module TrafficJunctionLight(
    N_RedLight, N_YellowLight, N_GreenLight,
    E_RedLight, E_YellowLight, E_GreenLight,
    S_RedLight, S_YellowLight, S_GreenLight,
    W_RedLight, W_YellowLight, W_GreenLight,
    EN, CLK
);
 
    output reg N_RedLight, N_YellowLight, N_GreenLight;
    output reg E_RedLight, E_YellowLight, E_GreenLight;
    output reg S_RedLight, S_YellowLight, S_GreenLight;
    output reg W_RedLight, W_YellowLight, W_GreenLight;

    input wire EN, CLK;

    reg [15:0] N_SETCOUNTER,E_SETCOUNTER,S_SETCOUNTER,W_SETCOUNTER;
    wire Clk_Out;

/*    Traffic_Light TL1(
                      .RedLight(N_RedLight), 
                      .YellowLight(N_YellowLight),
                      .GreenLight(N_GreenLight),
                      .EN(EN),
                      .CLK(CLK),
                      .SETCOUNTER(N_SETCOUNTER)
                        );
*/
    wire _NRedLight, _NYellowLight, _NGreenLight;
    wire _ERedLight, _EYellowLight, _EGreenLight;
    wire _SRedLight, _SYellowLight, _SGreenLight;
    wire _WRedLight, _WYellowLight, _WGreenLight;

    initial
        begin
            N_SETCOUNTER = 30;
            N_RedLight = 0;
            N_YellowLight = 0; 
            N_GreenLight = 0;           

            E_SETCOUNTER = 60;
            E_RedLight = 0;
            E_YellowLight = 0; 
            E_GreenLight = 0;           

            S_SETCOUNTER = 90;
            S_RedLight = 0;
            S_YellowLight = 0; 
            S_GreenLight = 0;           

            W_SETCOUNTER = 120;
            W_RedLight = 0;
            W_YellowLight = 0; 
            W_GreenLight = 0;           

        end

    always @(posedge CLK) 
    begin
        N_RedLight = _NRedLight;
        N_YellowLight = _NYellowLight;
        N_GreenLight = _NGreenLight;                    

        E_RedLight = _ERedLight;
        E_YellowLight = _EYellowLight;
        E_GreenLight = _EGreenLight;                    

        S_RedLight = _SRedLight;
        S_YellowLight = _SYellowLight;
        S_GreenLight = _SGreenLight;                    

        W_RedLight = _WRedLight;
        W_YellowLight = _WYellowLight;
        W_GreenLight = _WGreenLight;                    
    end
    
    Traffic_Light TL1(_NRedLight,_NYellowLight,_NGreenLight,EN,Clk_Out,N_SETCOUNTER);
    Traffic_Light TL2(_ERedLight,_EYellowLight,_EGreenLight,EN,Clk_Out,E_SETCOUNTER);
    Traffic_Light TL3(_SRedLight,_SYellowLight,_SGreenLight,EN,Clk_Out,S_SETCOUNTER);
    Traffic_Light TL4(_WRedLight,_WYellowLight,_WGreenLight,EN,Clk_Out,W_SETCOUNTER);

    HunderedMHz_To_OneHz uut_Clk(Clk_Out, CLK, EN);

endmodule