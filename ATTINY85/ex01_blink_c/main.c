#define F_CPU 1000000UL // (1MHz)
#include <avr/io.h>
#include <util/delay.h>

int main(void) {
    
    DDRB |= (1 << PB3); // Set PB3 as output

    while (1) {
        // Toggle the LED
        PORTB ^= (1 << PB3);
        _delay_ms(500); // half-second delay
    }

    return 0;
}
