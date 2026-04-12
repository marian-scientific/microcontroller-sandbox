riscv64-elf-as -march=rv32ec -mabi=ilp32e -o sdi.o sdi.S
riscv64-elf-ld -m elf32lriscv -T link.ld -o sdi.elf sdi.o
riscv64-elf-objcopy -O binary sdi.elf sdi.bin
minichlink -w sdi.bin flash -T
