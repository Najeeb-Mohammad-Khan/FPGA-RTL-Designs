`include "NandlandBased_MyUART_LED_SSD.v"
`include "NandlandBased_MyUART_TX.v"

module UART_BRAM_LOOPBACK(
    LEDOut, SSD_Out, SSD_Select, TxDone, Tx, Rx, En, Clk
);


    input wire Clk;
    input wire En;
    input wire Rx;

    output wire TxDone;
    output wire Tx;
    output wire [7:0] LEDOut;
    output wire [7:0] SSD_Out;
    output wire [3:0] SSD_Select;
    
    wire RxDataValid;
    wire [7:0] Rx_Buffer;
    reg [7:0] TxBuffer;


    reg [3:0] RxCounter;
    reg [2:0] TxCounter;
    reg EightBytesRxDone_Flag;
    reg StartTx;
    reg ByteTxDone_Flag;

    wire ena,wea;
    wire [3:0] addra;
    wire [7:0] dina;
    wire [7:0] douta;

    reg [3:0] Addr;
    reg [7:0] DataIn;
    wire [7:0] DataOut;
    wire DataReady;
    reg WriteEn;
    reg MemEn;
    reg StateTrigger;

    reg SetTxTrigger;
    reg DelayedTxDone;

    initial begin
        RxCounter = 0;
        EightBytesRxDone_Flag = 0;
        Addr = 0;
        DataIn = 0;
        WriteEn = 1;
        TxCounter = 0;
        ByteTxDone_Flag = 0;
        MemEn = 0;
        StateTrigger = 0;
        TxBuffer = 0;
        StartTx = 0;
        SetTxTrigger = 1;
        DelayedTxDone = 0;
    end
    
    wire TxTrigger;

//    assign TxTrigger = SetTxTrigger ? TxDone : StartTx ;
    assign TxTrigger = SetTxTrigger ? DelayedTxDone : StartTx ;

    always @(posedge Clk)
    begin
        SetTxTrigger <= StartTx;
    end


    reg d_T1,d_T2,d_T3,d_T4,d_T5,d_T6,d_T7,d_T8,d_T9,d_T10;

    always @(posedge Clk)
    begin
        d_T1 <= TxDone;
        d_T2 <= d_T1;
        d_T3 <= d_T2;
        d_T4 <= d_T3;
        d_T5 <= d_T4;
        d_T6 <= d_T5;
        d_T7 <= d_T6;
        d_T8 <= d_T7;
        d_T9 <= d_T8;
        d_T10 <= d_T9;
        DelayedTxDone <= d_T10;
    end

    
    NandlandBased_MyUART_LED_SSD uut(Rx_Buffer, RxDataValid, LEDOut, SSD_Out, SSD_Select, Clk, Rx, En);

    NandlandBased_MyUART_TX uut2(DataOut, TxDone, TxTrigger, Clk, Tx);

    blk_mem_gen_0 bram (
    .clka(Clk),    // input wire clka
    .ena(ena),      // input wire ena
    .wea(wea),      // input wire [0 : 0] wea
    .addra(addra),  // input wire [3 : 0] addra
    .dina(dina),    // input wire [7 : 0] dina
    .douta(douta)  // output wire [7 : 0] douta
    );

    MemControl bram_controller(
    .clka(Clk),
    .ena(ena),
    .wea(wea),
    .addra(addra),
    .dina(dina),
    .douta(douta),
    .DataReady(DataReady),
    .Addr(Addr),
    .DataOut(DataOut),
    .DataIn(DataIn),
    .WriteEn(WriteEn),
    .En(MemEn)
    );

    //State Machines Parameters
    parameter Idle        = 3'b000;
    parameter Start       = 3'b001;
    parameter RxData      = 3'b010;
    parameter TxData      = 3'b011;
    parameter Stop        = 3'b100;

    reg [2:0] StateMachine = 0;
    reg [2:0] Counter;
    reg [3:0] Tx_Delay;
    //reg TxTrigger_Reg;

    initial begin
        StateMachine = Idle;
        WriteEn = 0;
        DataIn = 0;
        MemEn = 0;
        Counter = 0;
        Tx_Delay = 0;
    end

    always @(posedge Clk) begin
       if(EightBytesRxDone_Flag == 1)
       begin        
        if(Tx_Delay == 15)
        begin
           StartTx <= 1;        
        end

        else begin
           StartTx <= 0;     
           Tx_Delay <= Tx_Delay + 1;               
        end
       end 

        else begin
           StartTx <= 0; 
        end

    end
    
    always @(posedge RxDataValid)
    begin
        if(RxCounter == 7)
        begin
            EightBytesRxDone_Flag <= 1;
            RxCounter <= 0;
        end

        else begin
            EightBytesRxDone_Flag <= 0;
            RxCounter <= RxCounter + 1;
        end
    end

    // always @(posedge DataReady) begin
    //     if(StateMachine == RxData)
    //     begin
    //         MemEn <= 0;                
    //     end
    // end

    always @(posedge Clk) begin
        if((RxDataValid == 1) || (TxDone == 1))
        begin            
            if(StateTrigger == 0)
            begin
                StateTrigger <= 1;
            end

            else begin
                StateTrigger <= 0;
            end
        end

        else begin
            if((StateMachine == Idle) && (Rx == 0))
            begin
                StateTrigger <= 1;                       
            end
            else begin
                StateTrigger <= 0;                                       
            end
        end
    end

    always @(posedge StateTrigger) begin
        if(En == 1)
        begin
            case (StateMachine) 
            Idle:
            begin
                if(Rx == 0)
                begin
                    StateMachine <= Start; 
                end

                else begin
                    StateMachine <= Idle;                
                    WriteEn <= 0;
                    MemEn <= 0;                    
                end
            end

            Start:
            begin
                StateMachine <= RxData; 
                WriteEn <= 1;
                DataIn <= Rx_Buffer;
                MemEn <= 1;                    
                Counter <= Counter + 1;                
            end

            RxData:
            begin
                if(Counter == 7)
                begin
                    StateMachine <= TxData;                    
                    WriteEn <= 0;
                    Addr <= Counter;
                    MemEn <= 1;            
                    Counter <= 0;        
                end

                else begin
                    StateMachine <= RxData;
                    WriteEn <= 1;
                    Addr <= Counter;
                    DataIn <= Rx_Buffer;
                    MemEn <= 1;    
                    Counter <= Counter + 1;                
                end
            end

            TxData:
            begin
                if(Counter == 7)
                begin
                    StateMachine <= Stop;                    
                    WriteEn <= 0;
                    Addr <= Counter;
                    MemEn <= 1;            
                    Counter <= 0;        
                end

                else begin
                    StateMachine <= TxData;
                    WriteEn <= 0;
                    TxBuffer <= DataOut;
                    Addr <= Counter;
                    MemEn <= 1;    
                    Counter <= Counter + 1;                
                end                
            end

            Stop:
            begin
                StateMachine <= Idle;                    
                WriteEn <= 0;
                MemEn <= 0;            
                Counter <= 0;                        
            end

            default:
            begin
                StateMachine <= Idle;                
                WriteEn <= 0;
                MemEn <= 0;
            end
                
            endcase    
        end

        else
        begin
                StateMachine <= Idle;                
                WriteEn <= 0;
                MemEn <= 0;
        end
    end

endmodule