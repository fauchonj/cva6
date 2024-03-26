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
        
def point_doubling(x1, y1, a, p):
    l = ((3*pow(x1,2)+a)*pow((2*y1), -1, p)) % p
    x3 = (l**2 - 2*x1) % p
    y3 = ((x1 - x3) * l - y1) % p
    return [x3, y3]

def point_addition(x1,y1,x2,y2,p):
    l = ((y2 - y1)*pow((x2 - x1), -1, p)) % p
    x3 = (l**2 - x1 - x2) % p
    y3 = ((x1 - x3) * l - y1) % p
    return [x3, y3]

# try:
n = 1
p = [0,5]
r = [0,5]
for i in range (11):
    if p[0] == r[0] and p[1] == r[1]:
        r = point_doubling(p[0], p[1], 2, 11)
    else:
        r = point_addition(r[0], r[1], p[0], p[1], 11)
    print(r, n)
    n += 1
# except:
#     print(n)




# if __name__== "__main__":
#     main()