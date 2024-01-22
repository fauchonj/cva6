//Module to do a modular substraction
// Entries: A, B, P
// Output: (A - B) mod P


module sub_modular_unit (
    input   logic           clk_i,
    input   logic           rst_ni,
    input   logic[63:0]     a_i,
    input   logic[63:0]     b_i,
    input   logic[63:0]     p_i,
    input   logic           sub_start_i,
    output  logic           sub_finish_o,
    output  logic[63:0]     sub_result_o
);

    logic[63:0] first_alu_o;
    logic[63:0] second_alu_o;
    logic       overflow;
    
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            overflow <= 0;
        end else begin
            
          if (sub_start_i) begin
            sub_finish_o = 0;
            first_alu_o = a_i + ~b_i + 1;
            overflow = p_i <= first_alu_o ? 1 : 0;
            second_alu_o = first_alu_o + p_i;
            if (overflow == 1'b1) begin
                sub_result_o = first_alu_o;
            end else begin
                sub_result_o = second_alu_o;
            end
            sub_finish_o = 1;
          end else begin
            sub_finish_o = 0;
            sub_result_o = 0;
          end
        end
    end
    
endmodule