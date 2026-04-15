.include "defs.inc"
 
.section .init
.global _start

_start:

    # ENABLE GPIOC & ADC1 ON APB2
    li   t0, RCC_APB2PCENR
    lw   t1, 0(t0)
    ori  t1, t1, (1 << IOPCEN) | (1 << ADC1EN)
    sw   t1, 0(t0)

    # CONFIGURE PC4 AS ANALOG INPUT
    li   t0, GPIOC_CFGLR
    lw   t1, 0(t0)
    li   t2, ~(PIN4)
    and t1, t1, t2
    ori  t1, t1, (ANALOG_INPUT<<PIN4_SHIFT)
    sw   t1, 0(t0)

    # SET ADC SAMPLE TIME TO MAX
    li   t0, ADC_SAMPTR2
    lw   t1, 0(t0)
    ori  t1, t1, (0x7 << 6)     # SMP2 = 0b111 (241.5 CYCLES)
    sw   t1, 0(t0)

    # SELECT CHANNEL 2 AS 1ST CONVERSION IN REGULAR SEQUENCE
    li   t0, ADC_RSQR3
    li   t1, 2                  # CHANNEL 2
    sw   t1, 0(t0)

    # ENABLE ADC
    li   t0, ADC_CTLR2
    lw   t1, 0(t0)
    ori  t1, t1, 0x1            # ADON = 1
    sw   t1, 0(t0)

    # RESET ADC CALIBRATION
    ori  t1, t1, (1 << 3)       # RSTCAL = 1
    sw   t1, 0(t0)
wait_rstcal:
    lw   t1, 0(t0)
    andi t2, t1, (1 << 3)
    bnez t2, wait_rstcal

    # CALIBRATE ADC
    lw   t1, 0(t0)
    ori  t1, t1, (1 << 2)       # CAL = 1
    sw   t1, 0(t0)
wait_cal:
    lw   t1, 0(t0)
    andi t2, t1, (1 << 2)
    bnez t2, wait_cal

adc_read:
    li   t0, ADC_CTLR2
    lw   t1, 0(t0)
    ori  t1, t1, 0x1            # ADON = 1
    sw   t1, 0(t0)

    li   t0, ADC_STATR
wait_eoc: # WAIT FOR END OF CONVERSION
    lw   t1, 0(t0)
    andi t2, t1, 0x2
    beqz t2, wait_eoc

    # READ ADC RESULT
    li   t0, ADC_RDATAR
    lw   a0, 0(t0)
    li t1, 0xFFF
    and a0, a0, t1          # 12-BIT VALUE IN A0

    # RETURN THE VALUE OVER SDI 
    srli a0, a0, 7 # DIVIDE BY 8 SO ITS [0,7]
    addi a0, a0, '0' # CONVERT TO ASCII
    slli a0, a0, 24 # SHIFT TO DUMP INTO SDI OUTPUT BUFFER

    li t0, SDI_OUTPUT
    li t1, '\n'<<8 + '='<<16 # ASSEMBLE SDI OUTPUT BUFFER
    add a0, a0, t1
    ori a0, a0, (SDI_OUTPUT_FLAGS + 3) # 3 CHARACTERS
    sw a0, 0(t0) # SEND VALUE

    j adc_read
