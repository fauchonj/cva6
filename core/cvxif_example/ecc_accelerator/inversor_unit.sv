//Module to do a modular inversion
// Entries: A P
// Output: (1/A) mod P

// A lot of notation of those files are from the article used for every units: High‑performance ECC processor architecture design for IoT security applications
// By Thirumalesu Kudithi1 and R. Sakthivel1

module inv_modular_unit (
    input   logic           clk_i,
    input   logic           rst_ni,
    input   logic[63:0]     a_i,
    input   logic[63:0]     p_i,
    input   logic           inv_start_i,
    output  logic           inv_finish_o,
    output  logic[63:0]     inv_result_o
);

    logic[63:0] x, y, u, v, u1, v1, x1, y1;
    logic geq, gt;
    
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            u   <= 0;
            v   <= 0;
            x   <= 0;
            y   <= 0;
            u1  <= 0;
            v1  <= 0;
            x1  <= 0;
            y1  <= 0;
            geq <= 0;
            gt  <= 0;
        end else begin
            
            inv_finish_o = 0;
            if (inv_start_i) begin
                u   = a_i;
                v   = p_i;
                x   = 1;
                y   = 0;
                u1  = 0;
                v1  = 0;
                x1  = 0;
                y1  = 0;
                geq = 0;
                gt  = 0;
                while (u != 1 && v != 1) begin
                    while (u[0] == 0) begin
                        u = u >> 1;
                        if (x[0] == 0) begin
                            x = x >> 1;
                        end else begin
                            x = (x + p_i) >> 1;
                        end
                    end
                    while (v[0] == 0) begin
                        v = v >> 1;
                        if (y[0] == 0) begin
                            y = y >> 1;
                        end else begin
                            y = (y + p_i) >> 1;
                        end
                    end
                    if (u >= v) begin
                        u = u - v;
                        if (x > y) begin
                            x = x - y;
                        end else begin
                            x = x + p_i - y;
                        end
                    end else begin
                        v = v - u;
                        if (y > x) begin
                            y = y - x;
                        end else begin
                            y = y + p_i - x;
                        end
                    end
                    // u1  = u[0] ? u : u >> 1;
                    // v1  = u[0] ? u : v >> 1;
                    // geq = (u1 >= v1) ? 1'b1 : 0; 
                    // u   = geq ? u1 + ~v1 + 1 : u1;
                    // v   = geq? v1 + ~u1 + 1 : v1;
                    // x1  = x[0] ? x + ~p_i + 1 : x;
                    // y1  = y[0] ? y + ~p_i + 1 : y;
                    // x1  = u[0] ? x : x1 >> 1;
                    // y1  = v[0] ? y : y1 >> 1;
                    // gt  = x1 > y1 ? 1'b1 : 0;
                    // x   = gt ? x1 + ~y1 + 1 : p_i + x1 + ~y1 + 1;
                    // y   = gt ? y1 + ~x1 + 1 : p_i + y1 + ~x1 + 1;
                    // x   = geq ? x : x1;
                    // y   = geq ? y : y1;
                end
                if (u == 1'b1) begin
                    inv_result_o = x;
                end else begin
                    inv_result_o = y;
                end
                inv_finish_o = 1'b1;
            end
          end
    end
    
endmodule