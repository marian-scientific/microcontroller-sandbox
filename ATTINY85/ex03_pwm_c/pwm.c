#define F_CPU 8000000UL
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

#define SERVO_PORT PB0
#define BUTTON_CW PB3 
#define BUTTON_CCW PB4

#define SERVO_DEBOUNCE 4 // higher means slower response

volatile uint8_t servo_pwm_duty = 127; // init servo to center
volatile uint8_t overflows = 0;
volatile uint8_t flag = 0; // activation of COMPB interrupt 

int main(void)
{

	DDRB |= (1 << SERVO_PORT);               // set servo port as output
	DDRB &= ~((1 << BUTTON_CW) | (1 << BUTTON_CCW)); // Button pins as inputs
	PORTB |= (1 << BUTTON_CW) | (1 << BUTTON_CCW);   // Enable internal pull-ups for buttons
	// timer 1 is used as it allows for more prescalers; here 16 is used to come from 8MHz to 500kHz (256 counts in 0.5ms, so the 2ms range from 0.5-2.5 extend over 4 timer overflows

	TCCR1 |= (1 << CS12) | (1 << CS10);      // set prescaler of timer1 to 16
	TIMSK |= (1 << TOIE1);  // enable overflow interrupt of timer1
	TIMSK |= (1 << OCIE1B); // enable compare match B interrupt of timer1
	sei();                  // enable interrupts

	while (1) {
		// Clockwise button pressed
		if ((PINB & (1 << BUTTON_CW))) {
			servo_pwm_duty++;
			if (servo_pwm_duty > 254) {
				servo_pwm_duty = 254;
			}
			_delay_ms(SERVO_DEBOUNCE); // debounce and smooth
		}
		// Counter-clockwise button pressed
		else if ((PINB & (1 << BUTTON_CCW))) {
			servo_pwm_duty--;
			if (servo_pwm_duty < 1) {
				servo_pwm_duty = 1;
			}
			_delay_ms(SERVO_DEBOUNCE); // debounce and smooth
		}
	}
}

ISR(TIMER1_OVF_vect){

	overflows++;

	if (overflows == 40){ // 20ms servo period (50Hz) (8e6/16) (nondiv clk/prescaler)
		PORTB |= (1 << SERVO_PORT); // servo PWM on
		overflows = 0;
	}

	if (overflows == (1+servo_pwm_duty/64)){ // spread 8-bit timer over 4 overflows
		flag = 1;
		OCR1B = 4*(servo_pwm_duty%64); // remainder onto COMPB interrupt
		TCNT1 = 0;
	}

}

ISR(TIMER1_COMPB_vect){

	if (flag){
		PORTB &= ~(1 << SERVO_PORT); // servo PWM off
		flag = 0;
	}    

}
