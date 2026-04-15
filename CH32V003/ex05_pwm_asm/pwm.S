.include "defs.inc"

.equ PSC_VAL,   7       # 8MHz / (7+1) = 1MHz
.equ ARR_VAL,   19999    # 1MHz / 20000 = 50Hz
.equ SERVO_MIN, 500     # 0.5ms
.equ SERVO_MAX, 2500     # 2.5ms
 
.section .init
.global _start

_start:
    call pwm_init
    
.loop:
    # SWEEP TO MINIMUM DUTY CYCLE
    li   t0, TIM1_CH1CVR
    li   t1, SERVO_MIN
    sw   t1, 0(t0)

    # PRINT "RT"
    li t0, SDI_OUTPUT
    li a0, 'R'<<8 + 'T'<<16 + '\n'<<24
    ori a0, a0, (SDI_OUTPUT_FLAGS + 3) # 3 CHARACTERS
    sw a0, 0(t0)

    # WAIT
    call delay_ms_500

    # SWEEP TO MAXIMUM DUTY CYCLE
    li   t0, TIM1_CH1CVR
    li   t1, SERVO_MAX
    sw   t1, 0(t0)

    # PRINT "LF"
    li t0, SDI_OUTPUT
    li a0, 'L'<<8 + 'F'<<16 + '\n'<<24
    ori a0, a0, (SDI_OUTPUT_FLAGS + 3) # 3 CHARACTERS
    sw a0, 0(t0)

    # WAIT
    call delay_ms_500

    # LOOP FOREVER
    j .loop

.global pwm_init
pwm_init:
    # ENABLE GPIOD & TIM1 ON APB2
    li   t0, RCC_APB2PCENR
    lw   t1, 0(t0)
    li   t2, (1<<IOPDEN)|(1<<TIM1EN)
    or   t1, t1, t2
    sw   t1, 0(t0)

    # SET PD2 AS MULTIPLEXED (ALTERNATE FUNCTION) PUSH-PULL OUTPUT, 50MHz
    li   t0, GPIOD_CFGLR
    lw   t1, 0(t0)
    li   t2, ~(PIN2)
    and  t1, t1, t2
    li   t2, (OUTPUT_50M_MPP<<PIN2_SHIFT)
    or   t1, t1, t2
    sw   t1, 0(t0)
 
    # SET PRESCALER
    li   t0, TIM1_PSC
    li   t1, PSC_VAL
    sw   t1, 0(t0)

    # SET PERIOD
    li   t0, TIM1_ATRLR
    li   t1, ARR_VAL
    sw   t1, 0(t0)

    # PWM MODE 1 ON CH1 (OC1M=110, OC1PE=1)
    li   t0, TIM1_CHCTLR1
    li   t1, (0x6 << 4) | (1 << 3)     # PWM MODE 1 (TYPICAL FOR SERVO) + PRELOAD ENABLE BIT
    sw   t1, 0(t0) 			# FYI: PWM MODE 1 MEANS HIGH FOR COUNTER < CCR1, 
					# LOW FOR COUNTER >= CCR1

    # TIMER1 CH1 OUTPUT ENABLE (CC1E = 1)
    li   t0, TIM1_CCER
    li   t1, 0x1
    sw   t1, 0(t0)

    # MAIN OUTPUT ENABLE FOR TIMER1 in BDTR (MOE = 1)
    li   t0, TIM1_BDTR
    li   t1, (1 << 15)
    sw   t1, 0(t0)

    # INITIAL PWM
    li   t0, TIM1_CH1CVR
    li   t1, 1500
    sw   t1, 0(t0)

    # START TIMER (CEN=1)
    li   t0, TIM1_CTLR1
    li   t1, 0x1
    sw   t1, 0(t0)

    ret

    # ROUGH 500 MS DELAY
delay_ms_500:
    li   t0, 2400000
delay_loop:
    addi t0, t0, -1
    bnez t0, delay_loop
    ret
