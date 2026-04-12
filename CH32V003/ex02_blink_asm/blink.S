.include "defs.inc"

.section .init
.global _start

_start:
    li t0, RCC_APB2PCENR
    lw t1, 0(t0)
    ori t1, t1, (1 << IOPCEN)
    sw t1, 0(t0)

    li t0, GPIOC_CFGLR
    lw t1, 0(t0)
    andi t1, t1, ~PIN0
    ori  t1, t1, (OUTPUT_2M_PP<<PIN0_SHIFT)
    sw t1, 0(t0)

    li t0, GPIOC_BSHR 
    li t1, (1 << 0) 
    li t2, (1 << 16)

loop:
    sw t1, 0(t0)
    jal ra, delay
    sw t2, 0(t0)
    jal ra, delay
    j loop

delay:
    li a0, 1000000
dec:    
    addi a0, a0, -1
    bnez a0, dec
    ret
