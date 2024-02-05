//Simple coprocessor implementing CVXIF interface with only one operation using
//CUSTOM3 returning rs1 + rs2


module ecc_accelerator_copro
    import cvxif_pkg::*;
    import ecc_instr::*;
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

    
    //------ Instruction decode ---------
    x_issue_resp_t instr_decode_o;
    assign x_issue_resp_o = instr_decode_o;

    instr_decoder_ecc #(
        .NbInstr   (ecc_instr::NbInstr),
        .CoproInstr(ecc_instr::CoproInstr)
    ) instr_decoder_i (
        .clk_i(clk_i),
        .x_issue_req_i (x_issue_req_i),
        .x_issue_resp_o(instr_decode_o)
    );
    
    //------ ------------------- ---------


    // --------Registre for the modular---------
     
    reg[63:0] modulo_q;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(!rst_ni) begin
            modulo_q <= 0;
        end else begin
            if (modular_we) begin
                modulo_q <= modulo_write;
            end
        end
    end
    // -----------------------------------------

    //------------State machine ----------------

    x_result_t result_o;
    logic add_start;
    logic sub_start;
    logic mul_start;
    logic inv_start;
    logic modular_we;
    logic issue_ready;
    logic result_valid;
    logic[63:0] modulo_write;
    logic[63:0] a_i;
    logic[63:0] b_i;

    state_machine state_machine_i (
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .add_finish_i(add_finish),
        .add_result_i(result_add),
        .sub_finish_i(sub_finish),
        .sub_result_i(result_sub),
        .mul_finish_i(mul_finish),
        .mul_result_i(mul_result),
        .inv_finish_i(inv_finish),
        .inv_result_i(inv_result),
        .x_issue_req_i(x_issue_req_i),
        .x_issue_req_accept_i(instr_decode_o.accept),
        .x_result_o(result_o),
        .add_start_o(add_start),
        .sub_start_o(sub_start),
        .mul_start_o(mul_start),
        .inv_start_o(inv_start),
        .x_result_valid_o(result_valid),
        .modular_write_o(modular_we),
        .x_issue_ready_o(issue_ready),
        .modulo_o(modulo_write),
        .a_o(a_i),
        .b_o(b_i)
    );

    assign x_result_valid_o = result_valid;
    assign x_issue_ready_o = issue_ready;
    assign x_result_o = result_o;

    // ------------Module addition
    logic[63:0] result_add;
    logic add_finish;
    add_modular_unit add_unit_t (   
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .a_i(a_i),
        .b_i(b_i),
        .p_i(modulo_q),
        .add_start_i(add_start),
        .result_o(result_add),
        .finish_o(add_finish)
    );

    // ------------Module substraction
    logic[63:0] result_sub;
    logic       sub_finish;
    sub_modular_unit sub_unit_t (   
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .a_i(a_i),
        .b_i(b_i),
        .p_i(modulo_q),
        .sub_start_i(sub_start),
        .sub_result_o(result_sub),
        .sub_finish_o(sub_finish)
    );

    // ------------Module multiplication
    logic[63:0] mul_result;
    logic       mul_finish;
    mul_modular_unit mul_unit_i (   
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .a_i(a_i),
        .b_i(b_i),
        .p_i(modulo_q),
        .mul_start_i(mul_start),
        .mul_result_o(mul_result),
        .mul_finish_o(mul_finish)
    );

    // ------------Module inversion
    logic[63:0] inv_result;
    logic       inv_finish;
    inv_modular_unit inv_unit_i (   
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .a_i(a_i),
        .p_i(modulo_q),
        .inv_start_i(inv_start),
        .inv_result_o(inv_result),
        .inv_finish_o(inv_finish)
    );
    
    // assign x_issue_ready_o = 1'b1;
    // always_comb begin
    //     x_result_o.data     = 0;
    //     x_result_valid_o    = instr_decode_o.accept ? 1 : 0;
    //     x_result_o.id       = instr_decode_o.accept ? x_issue_req_i.id : 0;
    //     x_result_o.rd       = instr_decode_o.accept ? x_issue_req_i.instr[11:7] : 0;
    //     x_result_o.we       = instr_decode_o.accept ? instr_decode_o.writeback : 0;
    //     x_result_o.exc      = 0;
    //     x_result_o.exccode  = 0;
    // end

endmodule
