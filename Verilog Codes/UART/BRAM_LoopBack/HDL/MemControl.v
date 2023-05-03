`timescale 1ns / 10ps

module MemControl(
    clka,ena,wea,addra,dina,douta,DataReady,Addr,DataOut,DataIn,WriteEn,En
//    clka,ena,wea,addra,dina,Addr,Data,WriteEn,En,Clk
    );

    input wire clka;
    output wire ena;
    output wire wea;
    output wire [3:0] addra;
    output wire [7:0] dina;
    input wire [7:0] douta;
    input wire En;
    output wire DataReady;

    input wire WriteEn;
    input wire [7:0] DataIn;
    output reg [7:0] DataOut;
    input wire [3:0] Addr;

    reg ena_Reg,wea_Reg;
    reg [3:0] addra_Reg;
    reg [7:0] dina_Reg;
    reg DataReady_Reg;
//    reg [7:0] RxDataBuffer;
    reg [1:0] Counter;

    assign ena = ena_Reg;
    assign wea = wea_Reg; 
    assign addra = addra_Reg;
    assign dina = dina_Reg;
    assign DataReady = DataReady_Reg;

    //Declaring the states 
    reg [1:0] StateMachine;

    //Local parametes for storing states
    parameter Idle      = 2'b00;
    parameter Start     = 2'b01;
    parameter ReadWrite = 2'b10;
    parameter Stop      = 2'b11;

    initial begin
        ena_Reg = 0;
        wea_Reg = 0;
        addra_Reg = 0;
        //douta_Reg = 0;
        StateMachine = Idle;
//        RxDataBuffer = 0;
        Counter = 0;
        DataOut = 0;
        DataReady_Reg = 0;
    end

    always @(douta) begin
       DataOut = douta;
    end

    always @(posedge clka) begin
        case (StateMachine)
            Idle:
            begin
                if(En == 1)
                begin
                    StateMachine <= Start;
                    DataReady_Reg <= 0;
                end
                else begin
                    StateMachine <= Idle;
                end
            end

            Start:
            begin
                ena_Reg <= 1;
                StateMachine <= ReadWrite;
            end

            ReadWrite:
            begin
                    //Reading operation
                    if(WriteEn == 0)
                    begin
                        if(Counter == 0)
                        begin
                            addra_Reg <= Addr;
                            wea_Reg <= 0;
                            StateMachine <= ReadWrite;
                            Counter <= Counter + 1;
                        end

                        else begin
                            //DataOut <= douta;   
                            StateMachine <= Stop;     
                            Counter <= 0;                       
                        end
                    end

                    //Writing operation
                    else begin
                        if(Counter == 0)
                        begin
                            addra_Reg <= Addr;
                            wea_Reg <= 1;
                            StateMachine <= ReadWrite;
                            Counter <= Counter + 1;
                            dina_Reg <= DataIn;
                        end

                        else begin
                            StateMachine <= Stop;     
                            Counter <= 0;  
                            wea_Reg <= 0;                     
                        end                        
                    end
                end

            Stop:
            begin
                ena_Reg <= 0;
                StateMachine <= Idle;
                DataReady_Reg <= 1;
            end
        endcase
    end

endmodule
