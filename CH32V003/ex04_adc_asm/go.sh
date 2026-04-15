riscv64-elf-as -march=rv32ec -mabi=ilp32e -o adc.o adc.S
riscv64-elf-ld -m elf32lriscv -T link.ld -o adc.elf adc.o
riscv64-elf-objcopy -O binary adc.elf adc.bin
minichlink -w adc.bin flash -T
