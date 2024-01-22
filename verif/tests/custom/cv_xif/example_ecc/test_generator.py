import random
import sys
import os
import subprocess

def generate_test_add(nb_test):
    path_file = os.getenv("ROOT_PROJECT") + "/verif/tests/custom/cv_xif/example_ecc/"
    with open(path_file + "test_add.txt", "w") as f:
        for _ in range(nb_test):
            p_i = random.randint(0, pow(2, 32) - 1)
            a_i = random.randint(0, p_i - 1)
            b_i = random.randint(0, p_i - 1)
            result = (a_i + b_i) % p_i
            f.write(f"{a_i},{b_i},{p_i},{result}\n")

def generate_test_sub(nb_test):
    path_file = os.getenv("ROOT_PROJECT") + "/verif/tests/custom/cv_xif/example_ecc/"
    with open(path_file + "test_sub.txt", "w") as f:
        for _ in range(nb_test):
            p_i = random.randint(0, pow(2, 32) - 1)
            a_i = random.randint(0, p_i - 1)
            b_i = random.randint(0, p_i - 1)
            result = (a_i - b_i) % p_i
            f.write(f"{a_i},{b_i},{p_i},{result}\n")



def main():
    if len(sys.argv) == 0:
        print("Error no arguments: python3 test_generator.py <nb_test_add> <nb_test_sub>")
    elif len(sys.argv) == 1:
            generate_test_add(int(sys.argv[1]))
    else:
        generate_test_add(int(sys.argv[1]))
        generate_test_sub(int(sys.argv[2]))
        


if __name__== "__main__":
    main()