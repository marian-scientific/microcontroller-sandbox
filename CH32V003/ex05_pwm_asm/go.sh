riscv64-elf-as -march=rv32ec -mabi=ilp32e -o pwm.o pwm.S
riscv64-elf-ld -m elf32lriscv -T link.ld -o pwm.elf pwm.o
riscv64-elf-objcopy -O binary pwm.elf pwm.bin
minichlink -w pwm.bin flash -T
