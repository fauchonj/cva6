module mult_tracer (
    input logic[65:0] c1,c2,c3,c4,c5,c6,
    input logic[63:0] c,i1,
    input logic clk_i, mul_start_i
);

    int f;
    initial begin
        f = $fopen("trace_mul.dasm", "w");
    end
    
    
    always_ff begin : trace
        if (mul_start_i) begin
            $fwrite(f, "multiplication etape: c1=0x%h, c2=0x%h, c3=0x%h, c4=0x%h, c5=0x%h, c6=0x%h, c=0x%h, i1=0x%h\n",
          c1, c2, c3, c4, c5, c6, c, i1);
        end
    end
    
    final $fclose(f);

endmodule