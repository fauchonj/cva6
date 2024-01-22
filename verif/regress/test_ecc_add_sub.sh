# where are the tools
if ! [ -n "$RISCV" ]; then
  echo "Error: RISCV variable undefined"
  return
fi

# install the required tools
source ./verif/regress/install-cva6.sh
source ./verif/regress/install-riscv-dv.sh
source ./verif/regress/install-riscv-compliance.sh
source ./verif/regress/install-riscv-tests.sh
source ./verif/regress/install-riscv-arch-test.sh


if ! [ -n "$DV_SIMULATORS" ]; then
  DV_SIMULATORS=vveri-testharness
fi

cd verif/sim/
python3 cva6.py --target cv32a60x --iss=$DV_SIMULATORS --iss_yaml=cva6.yaml --c_tests ../tests/custom/cv_xif/example_ecc/ecc_lib.c --linker=../tests/custom/common/test.ld\
  --gcc_opts="-static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -g ../tests/custom/common/syscalls.c ../tests/custom/common/crt.S -lgcc -I../tests/custom/env -I../tests/custom/common"
make -C ../.. clean
make clean_all

cd -
