riscv64-elf-as -march=rv32ec -mabi=ilp32e -o blink.o blink.S
riscv64-elf-ld -m elf32lriscv -T link.ld -o blink.elf blink.o
riscv64-elf-objcopy -O binary blink.elf blink.bin
minichlink -w blink.bin flash