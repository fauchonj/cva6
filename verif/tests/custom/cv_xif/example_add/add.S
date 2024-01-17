#include "macro.h"

  #-------------------------------------------------------------
   # Custom tests
  #-------------------------------------------------------------

  .globl main
main:

# core of the test
    LOAD_RS(a0, 0x1) # a0 <- 1
    LOAD_RS(a1, 0x3) # a1 <-3

    CUS_ADD(01100,01010,01011) # a2 <- a1 + a0
    LOAD_RS(a3, 0x4) # a3 <- 4
    beq a3, a2, pass # if a3 == a2 jump pass else continue

    LOAD_RS(a0, 0) # a0 <- 1
    jal exit # finish

    pass:
      LOAD_RS(a0, 0) # a0 <- 0
      jal exit # finish