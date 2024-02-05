//Module to do a modular addition
// Entries: A, B, P
// Output: (A + B) mod P

// A lot of notation of those files are from the article used for every units: High‑performance ECC processor architecture design for IoT security applications
// By Thirumalesu Kudithi1 and R. Sakthivel1

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

    logic[64:0] first_alu_o;
    logic[64:0] second_alu_o;
    logic       overflow;
    
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            overflow <= 0;
        end else begin
            
          if (add_start_i) begin
            finish_o = 0;
            first_alu_o = a_i + b_i;
            overflow = first_alu_o >= p_i ? 1 : 0;
            second_alu_o = first_alu_o + ~p_i + 1;
            if (!overflow) begin
                result_o = first_alu_o[63:0];
            end else begin
                result_o = second_alu_o[63:0];
            end
            finish_o = 1;
          end else begin
            finish_o = 0;
            result_o = 0;
          end
        end
    end
    
endmodule