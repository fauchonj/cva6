#ifndef _ECC_LIB_
#define  _ECC_LIB_

#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>

//                                            .insn r OPCODE, func3, func7, rd, rs1, rs2
#define CUS_LOAD_MOD(mod)       asm volatile(".insn r CUSTOM_1, 0x0, 0x0, x0, %0, x0"::"r"(mod):)
#define CUS_ADD_MOD(rd,rs1,rs2) asm volatile(".insn r CUSTOM_1, 0x1, 0x0, %0, %1, %2":"=r"(rd):"r"(rs1), "r"(rs2):)
#define CUS_SUB_MOD(rd,rs1,rs2) asm volatile(".insn r CUSTOM_1, 0x2, 0x0, %0, %1, %2":"=r"(rd):"r"(rs1), "r"(rs2):)
#define CUS_MUL_MOD(rd,rs1,rs2) asm volatile(".insn r CUSTOM_1, 0x3, 0x0, %0, %1, %2":"=r"(rd):"r"(rs1), "r"(rs2):)
#define CUS_INV_MOD(rd,rs1)     asm volatile(".insn r CUSTOM_1, 0x4, 0x0, %0, %1, x0":"=r"(rd):"r"(rs1):)

struct test_add {
    uint64_t a_i;
    uint64_t b_i;
    uint64_t p_i;
    uint64_t result;
};

struct test_sub {
    uint64_t a_i;
    uint64_t b_i;
    uint64_t p_i;
    uint64_t result;
};

struct test_mul {
    uint64_t a_i;
    uint64_t b_i;
    uint64_t p_i;
    uint64_t result;
};
struct test_inv {
    uint64_t a_i;
    uint64_t p_i;
    uint64_t result;
};

const struct test_add test_add1 = {0, 0, 1, 0};
const struct test_add test_add2 = {1, 3, 5, 4};
const struct test_add test_add3 = {1, 3, 4, 0};
const struct test_add test_add4 = {4, 3, 6, 1};

const struct test_sub test_sub1 = {0, 0, 1, 0};
const struct test_sub test_sub2 = {3, 1, 5, 2};
const struct test_sub test_sub3 = {3, 3, 4, 0};
const struct test_sub test_sub4 = {3, 4, 6, 5};

const struct test_mul test_mul1 = {0, 0, 1, 0};
const struct test_mul test_mul2 = {3, 2, 7, 6};
const struct test_mul test_mul3 = {3, 3, 9, 0};
const struct test_mul test_mul4 = {3, 4, 10, 2};
const struct test_inv test_inv1 = {1, 3, 1};
const struct test_inv test_inv2 = {3, 7, 5};
const struct test_inv test_inv3 = {6, 11, 2};
const struct test_inv test_inv4 = {3, 17, 6};
const struct test_add all_test_add[4] = {test_add1, test_add2, test_add3, test_add4};
const struct test_sub all_test_sub[4] = {test_sub1, test_sub2, test_sub3, test_sub4};
const struct test_mul all_test_mul[4] = {test_mul1, test_mul2, test_mul3, test_mul4};
const struct test_inv all_test_inv[4] = {test_inv1, test_inv2, test_inv3, test_inv4};

void execute_all_test(uint32_t, uint32_t);

#endif