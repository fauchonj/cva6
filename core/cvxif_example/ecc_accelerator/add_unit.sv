//Module to do a modular addition
// Entries: A, B, P
// Output: (A + B) mod P


module add_modular_unit (
    input   logic           clk_i,
    input   logic           rst_ni,
    input   logic[63:0]     a_i,
    input   logic[63:0]     b_i,
    input   logic[63:0]     p_i,
    input   logic           add_start_i,
    output  logic           finish_o,
    output  logic[63:0]     result_o
);

    logic[63:0] first_alu_o;
    logic[63:0] second_alu_o;
    logic       overflow;
    
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            overflow <= 0;
        end else begin
            
          if (add_start_i) begin
                finish_o = 0;
                first_alu_o <= a_i + b_i;
                overflow <= p_i - a_i - b_i <= 0 ? 1 : 0;
                second_alu_o <= first_alu_o + ~p_i + 1;
                if (!overflow) begin
                    result_o <= first_alu_o;
                end else begin
                    result_o <= second_alu_o;
                end
                finish_o = 1;
            end
        end
    end
    
endmodule