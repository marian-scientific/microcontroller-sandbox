#define F_CPU 8000000UL
#define BAUD 300

#include <avr/io.h>
#include <util/delay.h>

#define TX PB1
#define RX PB0
#define BIT_DELAY _delay_us(1000000 / BAUD);
#define HALF_BIT_DELAY _delay_us(1000000 / BAUD);

#define BUFFER_SIZE 32

char buffer[BUFFER_SIZE];

volatile uint8_t bufferIndex = 0;

void transmit(unsigned char data) {

	// start bit
	PORTB &= ~(1 << TX);
	BIT_DELAY;

	// data bits (LSB first)
	for (uint8_t i = 0; i < 8; i++) {
		if (data & (1 << i)) {
			PORTB |= (1 << TX);
		} else {
			PORTB &= ~(1 << TX);
		}
		BIT_DELAY;
	}

	// stop bit
	PORTB |= (1 << TX);
	BIT_DELAY;
}

void serial_print(char *str) {
	while (*str) {
		transmit(*str++);
	}
}

uint8_t receiveByte() {
	uint8_t data = 0;

	// Wait for start bit (falling edge)
	while (PINB & (1 << RX));
	HALF_BIT_DELAY; // Wait half a bit period

	// Read 8 data bits (LSB first)
	for (uint8_t i = 0; i < 8; i++) {
		BIT_DELAY;
		if (PINB & (1 << RX)) {
			data |= (1 << i);
		}
	}

	// Wait for stop bit (high)
	BIT_DELAY;

	return data;
}

void receiveString() {
	bufferIndex = 0;
	while (bufferIndex < BUFFER_SIZE - 1) {
		uint8_t receivedChar = receiveByte();
		buffer[bufferIndex++] = (char)receivedChar;

		if (receivedChar == '\r') {
			break; // end of string
		}
	}
}
int main(void) {

	DDRB |= (1 << TX); // set TX as output
	DDRB &= ~(1 << RX); // set RX as input

	_delay_ms(2000);

	serial_print("atTiny reset!\r\n");

	while(1) {

		_delay_ms(1000);
	
		for (uint8_t i = 0; i < BUFFER_SIZE; i++) {
			buffer[i] = 0;
		}

		serial_print("atTiny ready to receive data: ");

		receiveString();

		serial_print("data received on atTiny85: ");
		serial_print(buffer);
		serial_print("\r\n");

	}

	return 0;
}
