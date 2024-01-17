import cvxif_pkg::*;

`define IDLE    3'b000
`define ADD     3'b001
`define SUB     3'b010
`define MOD     3'b011
`define FINISH  3'b100

module state_machine (
    input   logic           clk_i,
    input   logic           rst_ni,
    input   logic           add_finish_i,
    input   logic[63:0]     add_result_i,
    input   logic           sub_finish_i,
    input   logic[63:0]     sub_result_i,
    input   x_issue_req_t   x_issue_req_i,
    input   logic           x_issue_req_accept_i,
    output  x_result_t      x_result_o,
    output  logic           x_result_valid_o,
    output  logic           add_start_o,
    output  logic           sub_start_o,
    output  logic           modular_write_o,
    output  logic           x_issue_ready_o,
    output  logic[63:0]     modulo_o,
    output  logic[63:0]     a_o,
    output  logic[63:0]     b_o
);
    
    reg[2:0] state;
    x_issue_req_t x_issue_in; 
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            state           <= `IDLE;
            x_result_o      <= 0;
            add_start_o     <= 0;
            sub_start_o     <= 0;
            modular_write_o <= 0;
            x_issue_in      <= 0;
            x_issue_ready_o <= 1'b1;
        end else begin
            case (state)
                `IDLE: begin
                    x_result_o          <= 0;
                    add_start_o         <= 0;
                    x_result_valid_o    <= 0;
                    sub_start_o         <= 0;
                    modular_write_o     <= 0;
                    x_issue_in          <= 0;
                    x_issue_ready_o     <= 1'b1;
                    if (x_issue_req_accept_i) begin
                        x_issue_in <= x_issue_req_i;
                        case (x_issue_in.instr[14:12])
                            3'b000: begin
                                state           <= `MOD;
                                modular_write_o <= 1'b1;
                                add_start_o     <= 0;
                                sub_start_o     <= 0;
                                x_issue_ready_o <= 0; 
                            end
                            3'b001: begin
                                state           <= `ADD;
                                b_o             <= x_issue_in.rs[1];
                                a_o             <= x_issue_in.rs[0];
                                modular_write_o <= 0;
                                add_start_o     <= 1;
                                sub_start_o     <= 0;
                                x_issue_ready_o <= 0;
                            end
                            3'b010: begin
                                state           <= `SUB;
                                modular_write_o <= 0;
                                add_start_o     <= 0;
                                sub_start_o     <= 1;
                                x_issue_ready_o <= 0;
                            end  
                            default: begin
                                state           <= `IDLE;
                                modular_write_o <= 0;
                                add_start_o     <= 0;
                                sub_start_o     <= 0;
                                x_issue_ready_o <= 0;
                            end  
                        endcase
                    end
                end
                `MOD: begin
                    x_result_o.data     <= 0;
                    x_result_valid_o    <= 1'b1;
                    x_result_o.id       <= x_issue_in.id;
                    modulo_o            <= x_issue_in.rs[0];
                    x_result_o.rd       <= 0;
                    x_result_o.we       <= 0;
                    x_result_o.exc      <= 0;
                    x_result_o.exccode  <= 0;
                    state               <= `IDLE;
                end
                `ADD: begin
                    if (add_finish_i) begin
                        x_result_o.data     <= add_result_i;
                        x_result_valid_o    <= 1;
                        x_result_o.id       <= x_issue_in.id;
                        x_result_o.rd       <= x_issue_in.instr[11:7];
                        x_result_o.we       <= 1;
                        x_result_o.exc      <= 0;
                        x_result_o.exccode  <= 0;
                        state               <= `IDLE;
                    end
                end 
                `SUB: begin
                    if (sub_finish_i) begin
                        x_result_o.data     <= sub_result_i;
                        x_result_valid_o    <= 1;
                        x_result_o.id       <= x_issue_in.id;
                        x_result_o.rd       <= x_issue_in.instr[11:7];
                        x_result_o.we       <= 1;
                        x_result_o.exc      <= 0;
                        x_result_o.exccode  <= 0;
                        state               <= `IDLE;
                    end
                end
            endcase    
        end
    end

endmodule