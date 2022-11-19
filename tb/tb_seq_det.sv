`timescale 1ps/1ps
`define CLK_PERIOD  10.0ns

module tb_seq_det ;
    
    // declare tb variables
    localparam SEQ_LEN      = 4;
    localparam ARRAY_LEN    = 10;

    logic                   clk;
    logic                   rst_n;
    logic                   tb_data_i;
    logic                   tb_detect_o;
    logic [SEQ_LEN-1:0]     array_seq;
    logic [ARRAY_LEN-1:0]   array_data; 
    logic [31:0]            error_count;
    logic [31:0]            seq_count;
    logic [31:0]            model_cont;

    // instantiate the design and connect to tb variables
    seq_det
    seq_det_io
    (
        .clk         ( clk          ),
        .rst_n       ( rst_n        ),
        .data_i      ( tb_data_i    ),
        .detect_o    ( tb_detect_o  )
    );

    always 
    begin : clk_gen
        clk = ~clk;
        #(`CLK_PERIOD/2);
    end

    // tasks

    task RESET_DUT;
        $display("*** Reset ***");
        rst_n = 0;
        #(`CLK_PERIOD*5);
        rst_n = 1;
    endtask

    task INIT_SIM;
        begin
            error_count = 0;
            seq_count   = 0;
            model_cont  = 0;
            tb_data_i   = 0;
            clk         = 1;
            rst_n       = 0;

            array_seq   = {1'b1, 1'b0, 1'b1, 1'b1};          
            array_data  = {1'b1, 1'b1, 1'b0, 1'b1, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0};
        end
    endtask 

    task MODEL;
        for (int i = 0; i < ARRAY_LEN; i++) begin
            if (array_data[i]==array_seq[0] && array_data[i+1]==array_seq[1] && array_data[i+2]==array_seq[2] && array_data[i+3]==array_seq[3]) begin
                model_cont = model_cont + 1;
            end
        end
    endtask 

    task OPERATION;
        begin
            for (int i = 0; i < ARRAY_LEN; i++) begin
                tb_data_i = array_data[i];
                #(`CLK_PERIOD);
                //#10;
                if (tb_detect_o) begin
                    seq_count = seq_count + 1;
                end
            end
        end
    endtask 

    task DISPLAY_TEST_RESULT;
        begin
            if (model_cont == seq_count) begin
                $display("*** SIMULATION PASSED ***");
                $display("number of sequences: %0d", seq_count);
            end
            else begin
                $display("*** SIMULATION FAILED ***");
                $display("expected: %0d, obtained: %0d", model_cont, seq_count);
            end

        end
    endtask 


    
    // main
    initial 
    begin : main
        $display("*** Model");
        
        MODEL();

        $display("*** Testbench started");

        INIT_SIM();
        RESET_DUT();
        OPERATION();
        DISPLAY_TEST_RESULT();

        $display("*** Simulation done");
        $finish; 
        //$stop; 
    end


endmodule