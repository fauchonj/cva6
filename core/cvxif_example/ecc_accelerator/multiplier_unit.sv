//Module to do a modular multiplication
// Entries: A, B, P
// Output: (A * B) mod P

// A lot of notation of those files are from the article used for every units: High‑performance ECC processor architecture design for IoT security applications
// By Thirumalesu Kudithi1 and R. Sakthivel1

module mul_modular_unit (
    input   logic           clk_i,
    input   logic           rst_ni,
    input   logic[63:0]     a_i,
    input   logic[63:0]     b_i,
    input   logic[63:0]     p_i,
    input   logic           mul_start_i,
    output  logic           mul_finish_o,
    output  logic[63:0]     mul_result_o
);

    logic[63:0] c;
    logic[65:0] c1;
    logic[65:0] c2;
    logic[65:0] c3;
    logic[65:0] c4;
    logic[65:0] c5;
    logic[65:0] c6;
    logic[63:0] i1;
    logic[64:0] p2;

    mult_tracer mult_tracer_t (
        .c1(c1),
        .c2(c2),
        .c3(c3),
        .c4(c4),
        .c5(c5),
        .c6(c6),
        .c(c),
        .i1(i1),    
        .clk_i(clk_i),
        .mul_start_i(mul_start_i)
    );

    assign p2 = p_i << 1'b1;
    
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            c = 0;
            c1= 0;
            c2= 0;
            c3= 0;
            c4= 0;
            c5= 0;
            c6= 0;
            i1= 0;
        end else begin
            
            mul_finish_o = 0;
            if (mul_start_i) begin
                c = 0;
                for (int i = 63; i >= 0; i--) begin
                    c1 = c;
                    c2 = c << 1;
                    for (int j = 63; j >=0; j--) begin
                        i1[j] = a_i[i] & b_i[j];
                    end
                    c3 = c2 + i1;
                    c4 = c3 - p_i;
                    c5 = c3 - p2;
                    if (c3 >= p2) begin
                        c6 = c5;
                    end else if (c3 >= p_i) begin
                        c6 = c4;
                    end else begin
                        c6 = c3;
                    end
                    c = c6;
                end
                mul_result_o = c;
                mul_finish_o = 1;
            end
          end
    end
    
endmodule