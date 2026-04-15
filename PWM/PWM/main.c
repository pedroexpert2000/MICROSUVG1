// PEDRO PABLO PORRAS
// LIBRERIA PWM0

/*****************************************************/

#include "PMW0.h"


#include <avr/io.h>
#include <stdint.h>

#define F_CPU 16000000

void initPWM0(uint8_t config_A, uint8_t config_B, uint8_t PWM_MODE, uint8_t prescaler);
void updateDutyCycle0A(uint8_t ciclo);
void updateDutyCycle0B(uint8_t ciclo);

int main(void)
{
	uint8_t duty = 0;

	initPWM0(PWM0A_NO_INVERTIDO, PWM0B_INVERTIDO, PWM_FAST_MODE, PWM_PRESCALER_8);

	while (1)
	{
		updateDutyCycle0A(duty);
		updateDutyCycle0B(duty);
		duty++;
	}
}

/*****************************************************/

void initPWM0(uint8_t config_A, uint8_t config_B, uint8_t PWM_MODE, uint8_t prescaler){
	
	DDRD |= (1<<DDD6) | (1<<DDD5);

	TCCR0A = 0;
	TCCR0B = 0;

	TCCR0A |= config_A | config_B | PWM_MODE;
	TCCR0B |= prescaler;
}

void updateDutyCycle0A(uint8_t ciclo){
	OCR0A = ciclo;
}

void updateDutyCycle0B(uint8_t ciclo){
	OCR0B = ciclo;
}