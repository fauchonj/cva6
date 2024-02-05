#include "ecc_lib.h"

// This ECC library will use the coprocessor descrideb in core/cvxif_example/ecc_accelerator
// A lot of notation of those files are from the article used for every units: High‑performance ECC processor architecture design for IoT security applications
// By Thirumalesu Kudithi1 and R. Sakthivel1


void execute_all_test(uint32_t nb_test_add, uint32_t nb_test_sub) {
    //Function to execute test present in the .h file
    uint32_t result = 0;
    uint32_t nb_test_pass = 0;
    for (int i = 0; i < nb_test_add; i++) {
        CUS_LOAD_MOD(all_test_add[i].p_i);
        CUS_ADD_MOD(result, all_test_add[i].a_i, all_test_add[i].b_i);
        if (result == all_test_add[i].result) {
            nb_test_pass++;
        } else {
            exit(nb_test_pass);
        }
    }
    for (uint32_t i = 0; i < nb_test_sub; i++) {
        CUS_LOAD_MOD(all_test_sub[i].p_i);
        CUS_SUB_MOD(result, all_test_sub[i].a_i, all_test_sub[i].b_i);
        if (result == all_test_sub[i].result) {
            nb_test_pass++;
        } else {
            exit(nb_test_pass);
        }
    };
    for (uint32_t i = 0; i < nb_test_sub; i++) {
        CUS_LOAD_MOD(all_test_mul[i].p_i);
        CUS_MUL_MOD(result, all_test_mul[i].a_i, all_test_mul[i].b_i);
        if (result == all_test_mul[i].result) {
            nb_test_pass++;
        } else {
            exit(nb_test_pass);
        }
    };
    for (uint32_t i = 0; i < nb_test_sub; i++) {
        CUS_LOAD_MOD(all_test_inv[i].p_i);
        CUS_INV_MOD(result, all_test_inv[i].a_i);
        if (result == all_test_inv[i].result) {
            nb_test_pass++;
        } else {
            exit(nb_test_pass);
        }
    };
}

struct point_curve point_doubling(struct point_curve p) {
    struct point_curve result;
    uint64_t t1     = 2;
    uint64_t t2     = 0;
    uint64_t t3     = 0;
    uint64_t t4     = 2;
    uint64_t t5     = 0;
    uint64_t t6     = 0;
    uint64_t t7     = 0;
    uint64_t t8     = 0;
    uint64_t t9     = 2;
    uint64_t t10    = 0;
    uint64_t t11    = 0;
    uint64_t t12    = 0;
    uint64_t t13    = 0;

    CUS_MUL_MOD(t1  , t1        , p.y);
    CUS_MUL_MOD(t2  , p.x       , p.x);
    CUS_INV_MOD(t3  , t1);
    CUS_MUL_MOD(t4  , t4        , t2);
    CUS_ADD_MOD(t5  , t4        , t2);
    CUS_ADD_MOD(t6  , t5        , (p.curve).a);
    CUS_MUL_MOD(t7  , t6        , t3); //lambda
    CUS_MUL_MOD(t8  , t7        , t7);
    CUS_MUL_MOD(t9  , t9        , p.x);
    CUS_SUB_MOD(t10 , t8        , t9); //x3
    CUS_SUB_MOD(t11 , p.x       , t10);
    CUS_MUL_MOD(t12 , t11       , t7);
    CUS_SUB_MOD(t13 , t12       , p.y); //y3

    result.x        = t10;
    result.y        = t13;
    result.curve    = p.curve;
    return result;

}

struct point_curve point_addition(struct point_curve p, struct point_curve q) {
    struct point_curve result;
    uint32_t t1     = 2;
    uint32_t t2     = 0;
    uint32_t t3     = 0;
    uint32_t t4     = 2;
    uint32_t t5     = 0;
    uint32_t t6     = 0;
    uint32_t t7     = 0;
    uint32_t t8     = 0;
    uint32_t t9     = 2;
    uint32_t t10    = 0;
    uint32_t t11    = 0;
    uint32_t t12    = 0;
    uint32_t t13    = 0;

    CUS_SUB_MOD(t1   , q.x       , p.x);
    CUS_SUB_MOD(t2   , q.y       , p.y);
    CUS_INV_MOD(t3   , t1);
    CUS_MUL_MOD(t4   , t2        , t3); //lambda
    CUS_MUL_MOD(t5   , t4        , t4);
    CUS_SUB_MOD(t6   , t5        , p.x);
    CUS_SUB_MOD(t7   , t6        , q.x); //x3
    CUS_SUB_MOD(t8   , p.x       , t7);
    CUS_MUL_MOD(t9   , t8        , t4);
    CUS_SUB_MOD(t10  , t9        , p.y); //y3

    result.x        = t7;
    result.y        = t10;
    result.curve    = p.curve;
    return result;

}

struct point_curve point_scalar_multiplication(uint32_t k, struct point_curve p) {
    uint32_t msb = 0;
    uint32_t i = 31;
    while (msb == 0) {
        if ((1 << i) & k) {
            msb = i;
        }
        i--;
    }
    struct point_curve result = p;
    for (uint16_t j = msb - 1; j >= 0; j--) {
        result = point_doubling(result);
        if (k & (1 << j)) {
            result = point_addition(result, p);
        }
    }
    return result;
}

struct keys key_gen(struct pub_dom dom) {
    // Normaly d it supposed to choose randomly between 1 and order -1
    // Because of simulation random not existing so it will be determinist just for test
    uint32_t d;
    if (dom.order & 1) {
        d = (dom.order - 1) / 2;        
    } else {
        d = dom.order / 2;
    }

    struct point_curve Q = point_scalar_multiplication(d, dom.p_init);
    struct keys result = {Q, d};
    return result;
}

struct cipher_text curve_encryption(struct pub_dom dom, struct point_curve pub_key, struct point_curve M) {
    // Normaly k it supposed to choose randomly between 1 and order -1
    // Because of simulation random not existing so it will be determinist just for test
    uint32_t k;
    if (dom.order & 1) {
        k = (dom.order - 1) / 2;        
    } else {
        k = dom.order / 2;
    }
    struct point_curve C1 = point_scalar_multiplication(k, dom.p_init);
    struct point_curve C2 = point_scalar_multiplication(k, pub_key);
    C2 = point_addition(M, C2);
    struct cipher_text ct = {C1, C2};
    return ct;
}

struct point_curve curve_decryption(struct pub_dom dom, uint64_t sec_key, struct cipher_text ct) {
    struct point_curve M = point_scalar_multiplication(~sec_key + 1, ct.C1);
    M = point_addition(ct.C2, M);
    return M;
}

void main() {
    //Function to test functions not usable
    uint32_t p = 11;
    CUS_LOAD_MOD(p);
    struct point_curve result = point_addition(test_point_add1.p, test_point_add1.q);
    if (result.x != test_point_add1.r.x || result.y != test_point_add1.r.y) {
        exit(1);
    }

    struct point_curve result2 = point_doubling(test_point_dbl1.p);
    if (result2.x != test_point_dbl1.r.x || result2.y != test_point_dbl1.r.y) {
        exit(2);
    }
    exit(0);
}