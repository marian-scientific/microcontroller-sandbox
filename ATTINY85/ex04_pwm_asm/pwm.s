__SP_H__ = 0x3e ; stack pointer
__SP_L__ = 0x3d
__SREG__ = 0x3f ; status register (aka flags)
__zero_reg__ = 1
.text
.global	main
main:

	sbi 0x17,0 ; sets 0th bit at DDRB (aka io) to output on PB0
	cbi 0x17,3 ; sets 3th bit at DDRB (aka io) to input on PB3
	cbi 0x17,4 ; sets 4th bit at DDRB (aka io) to input on PB4
	
	sbi 0x18,3 ; toggle pull up (NOTE: CHECK!) on PORTB pins 3 and 4
	sbi 0x18,4

	; sbi only works from address 0x00 to 0x1F

	ldi r24,5
	out 0x30,r24
	; sets CS10 on TCCR1 (timer control reg)
	; sets CS12 on TCCR1 (timer control reg) 
	; together that's 16 prescaler, which takes 8MHz down to 500kHz, times 256 cycles of 8-bit timer, aka 0.5ms period

	ldi r24,36
	out 0x39,r24

	; TIMSK |= (1 << TOIE1);  // enable overflow interrupt of timer1
	; TIMSK |= (1 << OCIE1B); // enable compare match B interrupt of timer1

	; enables interrupts
	sei

	; "variables" stored in registers	
	ldi r21,0 ; overflow comparison flag
	ldi r22,0 ; overflows
	ldi r23,127 ; servo_pwm_duty

.loop: ; while(1)
	sbis 0x16,3 ; skip next instruction if PB3 is pushed!
	rjmp .pb3_not_pushed ; aka if PB3 is not pushed, jump to L3

	inc r23	
	cpi r23,255
	brne .delay

	ldi r23,254 ; extremes

; this is the delay function, weird but calibrated
.delay: ; each loop iteration is 4 clock cycles at 8MHz
	ldi r30,lo8(5999)
	ldi r31,hi8(5999)
1:	sbiw r30,1
	brne 1b
	rjmp .
	nop
	rjmp .loop

.pb3_not_pushed:
	sbis 0x16,4 ; skip next instruction if PB4 is pushed!
	rjmp .loop ; aka if PB3 is not pushed, jump to while loop

	dec r23
	brne .delay ; if we hit zero, go back to 1, then continue loop
	ldi r23,1
	rjmp .delay

.global	__vector_4 ; ISR at 0x0004 is TIM1_OVF_ISR (overflow interrupt)
__vector_4:

	inc r22
	cpi r22,40 ; counts 40 overflows

	brne .period_already_running
	sbi 0x18,0 ; turns ON servo pulse (on PB0)
	clr r22

.period_already_running:
	mov r25,r22 ; overflows
	mov r24,r23 ; duty cycle

	rol r24
	rol r24
	rol r24

	; aka right shift 6, aka take top 2 bits aka 128+64

	andi r24,3 ; & 0000,0011
	
	; all this to integer divide by 64

	inc r24	; +1
	cpse r25,r24 ; see if we are in the final overflow domain
	rjmp .ISR4_break

	ldi r21,1	; set flag

	mov r24,r23
	lsl r24	; *2
	lsl r24 ; *4
	out 0x2b,r24 ; sets the remainder
	out 0x2f,__zero_reg__ ; sets timer back to zero
.ISR4_break:
	reti

.global	__vector_9 ; address 0x0009 is TIM1_COMPB_ISR
__vector_9:
	cp r21, __zero_reg__
	breq .ISR9_break
	cbi 0x18,0 ; turns OFF the servo pulse (on PB0)
	clr r21
.ISR9_break:
	reti
