// This ECC library will use the coprocessor descrideb in core/cvxif_example/ecc_accelerator
// A lot of notation of those files are from the article used for every units: High‑performance ECC processor architecture design for IoT security applications
// By Thirumalesu Kudithi1 and R. Sakthivel1


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

struct elliptic_curve {
    uint64_t a;
    uint64_t b;
}; // y^2 = x^3 + ax + b

struct point_curve {
    struct elliptic_curve curve;
    uint64_t x;
    uint64_t y;
};

struct test_point_add {
    struct point_curve p;
    struct point_curve q;
    struct point_curve r;
};

struct test_point_dbl {
    struct point_curve p;
    struct point_curve r;
};

const struct elliptic_curve curve1= {2, 3};

const struct point_curve p1 = {curve1, 0, 6};
const struct point_curve q1 = {curve1, 2, 2};
const struct point_curve r1 = {curve1, 2, 9};

const struct test_point_add test_point_add1 = {p1, q1, r1};

const struct point_curve p2 = {curve1, 2, 2};
const struct point_curve r2 = {curve1, 0, 5};

const struct test_point_dbl test_point_dbl1 = {p2, r2};


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
struct point_curve point_doubling(struct point_curve);
struct point_curve point_addition(struct point_curve, struct point_curve);
struct point_curve point_scalar_multiplication(uint32_t, struct point_curve);


//Next function are for the ecc using the coprocessor, it's implementing ElGamal encryption scheme
// Describe in Guide to Elliptic Curve Cryptography - D. Hankerson, A. Menezes, S. Vanstone.pdf at the page 14

struct pub_dom {
    uint64_t p;
    struct elliptic_curve curve;
    struct point_curve p_init;
    uint64_t order;
};

struct keys {
    struct point_curve pub_key;
    uint64_t sec_key;
};

struct cipher_text {
    struct point_curve C1;
    struct point_curve C2;
};

struct keys key_gen(struct pub_dom);
struct cipher_text curve_encryption(struct pub_dom, struct point_curve pub_key, struct point_curve);
struct point_curve curve_decryption(struct pub_dom, uint64_t, struct cipher_text);
#endif