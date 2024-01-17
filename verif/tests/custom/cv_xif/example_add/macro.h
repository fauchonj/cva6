#define CUS_ADD(rd,rs1,rs2) .word 0b##0000000##rs2####rs1##001##rd##0101011
#define LOAD_RS(rs,value) li rs, value