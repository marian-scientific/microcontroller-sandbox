#include "ch32fun.h"
#include <stdio.h>

int main()
{
	SystemInit();

	// Enable GPIOs
	RCC->APB2PCENR |= RCC_APB2Periph_GPIOD | RCC_APB2Periph_GPIOC;

	// GPIO C0 Push-Pull
	GPIOC->CFGLR &= ~(0xf<<(4*0));
	GPIOC->CFGLR |= (GPIO_Speed_10MHz | GPIO_CNF_OUT_PP)<<(4*0);

	while(1)
	{
		GPIOC->BSHR = (1<<0);
		Delay_Ms( 250 );
		GPIOC->BSHR = (1<<16);
		Delay_Ms( 250 );
	}
}
