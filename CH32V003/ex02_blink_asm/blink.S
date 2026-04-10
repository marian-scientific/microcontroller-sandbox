.section .init
.global _start

_start:
    # --- 1. Enable GPIOC Clock ---
    # RCC_APB2PCENR address is 0x40021018
    # Bit 4 enables IOPC (GPIOC)
    li t0, 0x40021018
    lw t1, 0(t0)
    ori t1, t1, (1 << 4)
    sw t1, 0(t0)

    # --- 2. Configure PC0 as Output (10MHz Push-Pull) ---
    # GPIOC_CFGLR address is 0x40011000
    # Each pin takes 4 bits. For PC0, bits 0-3. 
    # Value 0x1 is Output 10MHz, 0x0 is Push-Pull. Total: 0x1
    li t0, 0x40011000
    lw t1, 0(t0)
    andi t1, t1, 0xfffffff0  # Clear bottom 4 bits
    ori  t1, t1, 0x00000001  # Set bottom 4 bits to 0x1
    sw t1, 0(t0)

    # Addresses for Toggling
    li t0, 0x4001100c        # GPIOC_BSHR (Bit Set/High Register)
    li t1, (1 << 0)          # Bit 0 for PC0 (Set)
    li t2, (1 << 16)         # Bit 16 for PC0 (Reset/Clear)

loop:
    sw t1, 0(t0)             # Turn LED ON
    jal ra, delay            # Wait
    sw t2, 0(t0)             # Turn LED OFF
    jal ra, delay            # Wait
    j loop

delay:
    li a0, 1000000           # Adjust this for speed
1:
    addi a0, a0, -1
    bnez a0, 1b
    ret
