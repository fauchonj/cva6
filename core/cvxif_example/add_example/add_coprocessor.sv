//Simple coprocessor implementing CVXIF interface with only one operation using
//CUSTOM3 returning rs1 + rs2


module cvxif_example_coprocessor_add
    import cvxif_pkg::*;
    import add_instr::*;
(
    input  logic        clk_i,        // Clock
    input  logic        rst_ni,       // Asynchronous reset active low
    input  cvxif_req_t  cvxif_req_i,
    output cvxif_resp_t cvxif_resp_o
);

    //Compressed interface
    logic               x_compressed_valid_i;
    logic               x_compressed_ready_o;
    x_compressed_req_t  x_compressed_req_i;
    x_compressed_resp_t x_compressed_resp_o;
    //Issue interface
    logic               x_issue_valid_i;
    logic               x_issue_ready_o;
    x_issue_req_t       x_issue_req_i;
    x_issue_resp_t      x_issue_resp_o;
    //Commit interface
    logic               x_commit_valid_i;
    x_commit_t          x_commit_i;
    //Memory interface
    logic               x_mem_valid_o;
    logic               x_mem_ready_i;
    x_mem_req_t         x_mem_req_o;
    x_mem_resp_t        x_mem_resp_i;
    //Memory result interface
    logic               x_mem_result_valid_i;
    x_mem_result_t      x_mem_result_i;
    //Result interface
    logic               x_result_valid_o;
    logic               x_result_ready_i;
    x_result_t          x_result_o;

    assign x_compressed_valid_i            = cvxif_req_i.x_compressed_valid;
    assign x_compressed_req_i              = cvxif_req_i.x_compressed_req;
    assign x_issue_valid_i                 = cvxif_req_i.x_issue_valid;
    assign x_issue_req_i                   = cvxif_req_i.x_issue_req;
    assign x_commit_valid_i                = cvxif_req_i.x_commit_valid;
    assign x_commit_i                      = cvxif_req_i.x_commit;
    assign x_mem_ready_i                   = cvxif_req_i.x_mem_ready;
    assign x_mem_resp_i                    = cvxif_req_i.x_mem_resp;
    assign x_mem_result_valid_i            = cvxif_req_i.x_mem_result_valid;
    assign x_mem_result_i                  = cvxif_req_i.x_mem_result;
    assign x_result_ready_i                = cvxif_req_i.x_result_ready;

    assign cvxif_resp_o.x_compressed_ready = x_compressed_ready_o;
    assign cvxif_resp_o.x_compressed_resp  = x_compressed_resp_o;
    assign cvxif_resp_o.x_issue_ready      = x_issue_ready_o;
    assign cvxif_resp_o.x_issue_resp       = x_issue_resp_o;
    assign cvxif_resp_o.x_mem_valid        = x_mem_valid_o;
    assign cvxif_resp_o.x_mem_req          = x_mem_req_o;
    assign cvxif_resp_o.x_result_valid     = x_result_valid_o;
    assign cvxif_resp_o.x_result           = x_result_o;

    //Compressed interface
    assign x_compressed_ready_o            = '0;
    assign x_compressed_resp_o.instr       = '0;
    assign x_compressed_resp_o.accept      = '0;

    assign x_issue_ready_o = 1'b1;

    instr_decoder_add #(
        .NbInstr   (add_instr::NbInstr),
        .CoproInstr(add_instr::CoproInstr)
    ) instr_decoder_i (
        .clk_i         (clk_i),
        .x_issue_req_i (x_issue_req_i),
        .x_issue_resp_o(x_issue_resp_o)
    );

    logic x_result_valid_q;
    logic x_result_valid_n;
    logic x_result_valid;
    logic[31:0] result;
    logic[31:0] result_q;
    logic[31:0] result_n;

    always_comb begin : calcul
        if (x_issue_resp_o.accept) begin
            result <= x_issue_req_i.rs[0] + x_issue_req_i.rs[1];
            x_result_valid <= 1;
        end
        else begin
            x_result_valid <= 0;
        end
    end

    typedef struct packed {
    x_issue_req_t  req;
    x_issue_resp_t resp;
    } x_issue_t;

    x_issue_t issue_q;
    x_issue_t issue_n; 

    always_ff @(posedge clk_i or negedge rst_ni) begin : end_calc
        if(!rst_ni) begin
            
            x_result_valid_q <= 0;
            x_result_valid_n <= 0;
        end else begin
            issue_q.req <= x_issue_req_i;
            issue_q.resp <= x_issue_resp_o;
            result_q <= result;
            x_result_valid_q <= x_result_valid;
            x_result_valid_n <= x_result_valid_q;
            result_n <= result_q;
            issue_n <= issue_q;

        end
    end

    always_comb begin
        x_result_o.data    = x_result_valid_n ? result_n : 0 ;
        x_result_valid_o   = x_result_valid_n ? 1 : 0;
        x_result_o.id      = x_result_valid_n ? issue_n.req.id : issue_q.req.id;
        x_result_o.rd      = x_result_valid_n ? issue_n.req.instr[11:7] : issue_q.req.instr[11:7];
        x_result_o.we      = x_result_valid_n ? issue_n.resp.writeback && issue_n.resp.accept : issue_q.resp.writeback && issue_q.resp.accept;
        x_result_o.exc     = 0;
        x_result_o.exccode = 0;
    end

endmodule
