/*
 * PWM1.c
 *
 * Created: 13/04/2026 22:25:46
 *  Author: Pedro Porras
 */ 


#include "PWM1.h"

void initPWM1(uint8_t config_A, uint8_t config_B, uint8_t PWM_MODE, uint8_t prescaler){
	
	DDRB |= (1<<DDB1) | (1<<DDB2);

	TCCR1A = 0;
	TCCR1B = 0;

	TCCR1A |= config_A | config_B | PWM_MODE;
	TCCR1B = PWM_WGM12 | prescaler;
}

void setPWM1A(uint16_t ciclo1){
	OCR1A = ciclo1;
}

void setPWM1B(uint16_t ciclo1){
	OCR1B = ciclo1;
}
