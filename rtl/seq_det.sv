module seq_det 
    (   input   logic   clk,
        input   logic   rst_n,
        input   logic   data_i,
        output  logic   detect_o
    );

    enum logic[1:0] { state_0, state_1, state_2, state_3 } present_state, next_state;


    always_ff @( posedge clk, negedge rst_n ) 
    begin
        if (~rst_n) begin
            present_state <= state_0;
        end else begin
            present_state <= next_state;
        end
    end

    // we detect 1011
    always_comb 
    begin
        case (present_state)
            state_0:
            begin
                if (data_i == 1) begin
                    next_state = state_1;
                end 
                else begin
                    next_state = present_state;
                end 

                detect_o = 0;
            end
       
            state_1:
            begin
                if (data_i == 0) begin
                    next_state = state_2;
                end 
                else begin
                    next_state = state_1;
                end

                detect_o = 0;
            end

            state_2:
            begin
                if (data_i == 1) begin
                    next_state = state_3;
                end 
                else begin
                    next_state = state_0;
                end 

                detect_o = 0;
            end

            state_3:
            begin
                if (data_i == 1) begin
                    next_state = state_1;
                    detect_o = 1;
                end 
                else begin
                    next_state = state_2;
                    detect_o = 0;
                end
            end
        endcase
    end
    
endmodule