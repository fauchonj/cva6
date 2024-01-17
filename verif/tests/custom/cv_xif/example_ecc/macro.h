//Macro for coding test for ecc accelerator

#define CUS_LOAD_MOD(mod) .word 0b##000000000000##mod##000000000101011
#define CUS_ADD_MOD(rd,rs1,rs2) .word 0b##0000000##rs2####rs1##001##rd##0101011
#define LOAD_RS(rs,value) li rs, value