#include "ecc_lib.h"

void execute_all_test(uint32_t nb_test_add, uint32_t nb_test_sub) {
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
            exit(0);
        }
    }
}

void main() {
    execute_all_test(4,4);
    exit(0);
}