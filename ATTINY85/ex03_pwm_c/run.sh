avr-gcc -mmcu=attiny85 -Wall -Os pwm.c -o main.elf
avr-objcopy -j .text -j .data -O ihex main.elf main.hex
sudo avrdude -c usbasp -p t85 -U lfuse:w:0xE2:m
sudo avrdude -c usbasp -p t85 -U hfuse:w:0xDF:m
sudo avrdude -c usbasp -p t85 -U flash:w:main.hex:i