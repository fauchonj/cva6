package ecc_instr;

  typedef struct packed {
    logic [31:0]              instr;
    logic [31:0]              mask;
    cvxif_pkg::x_issue_resp_t resp;
  } copro_issue_resp_t;

  // 2 Possible RISCV instructions for Coprocessor
  parameter int unsigned NbInstr = 3
  ;
  parameter copro_issue_resp_t CoproInstr[NbInstr] = '{
      '{
          instr: 32'b00000_00_00000_00000_0_00_00000_0101011,  // custom1 opcode
          mask: 32'b00000_00_00000_00000_1_11_00000_1111111,   // ECC_add
          resp : '{
              accept : 1'b1,
              writeback : 1'b0,
              dualwrite : 1'b0,
              dualread : 1'b0,
              loadstore : 1'b0,
              exc : 1'b0
          }
      },
      '{
        instr: 32'b00000_00_00000_00000_0_01_00000_0101011,  // custom1 opcode
        mask: 32'b00000_00_00000_00000_1_11_00000_1111111,   // ECC_add
        resp : '{
            accept : 1'b1,
            writeback : 1'b1,
            dualwrite : 1'b0,
            dualread : 1'b0,
            loadstore : 1'b0,
            exc : 1'b0
        }
      },
      '{
        instr: 32'b00000_00_00000_00000_0_10_00000_0101011,  // custom1 opcode
        mask: 32'b00000_00_00000_00000_1_11_00000_1111111,   // ECC_sub
        resp : '{
            accept : 1'b1,
            writeback : 1'b1,
            dualwrite : 1'b0,
            dualread : 1'b0,
            loadstore : 1'b0,
            exc : 1'b0
        }
      }
  };

endpackage
