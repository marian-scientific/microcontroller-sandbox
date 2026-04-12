.include "defs.inc"

.section .init
.global _start

_start:
	li t0, SDI_OUTPUT
	li a0, 'H'<<8 + 'e'<<16 + 'y'<<24
	ori a0, a0, (SDI_OUTPUT_FLAGS + 3) # 3 CHARACTERS
	sw a0, 0(t0)

loop:
	j loop
