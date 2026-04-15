/*
 * PMW0.c
 *
 * Created: 13/04/2026 19:38:58
 *  Author: Pedro Porras
 */ 

#include "pwm0.h"

void initPWM0(uint8_t config_A, uint8_t config_B, uint8_t PWM_MODE, uint8_t prescaler){
	DDRD |= (1<<DDD6) | (1<<DDD5);

	TCCR0A = 0;
	TCCR0B = 0;

	TCCR0A |= config_A | config_B | PWM_MODE;
	TCCR0B |= prescaler;
}

void setPWM0A(uint8_t ciclo){
	OCR0A = ciclo;
}

void setPWM0B(uint8_t ciclo){
	OCR0B = ciclo;
}