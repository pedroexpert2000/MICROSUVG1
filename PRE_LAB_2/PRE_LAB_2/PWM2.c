/*
 * PWM2.c
 *
 * Created: 15/04/2026 16:21:17
 *  Author: Pedro Porras
 */ 


#include "PWM2.h"

void initPWM2(uint8_t config_A, uint8_t config_B, uint8_t PWM_MODE, uint8_t prescaler){
	
	DDRD |= (1<<DDD3);
    DDRB |= (1<<DDB3); 
	 
	TCCR2A = 0;
	TCCR2B = 0;

	TCCR2A |= config_A | config_B | PWM_MODE;
	TCCR2B |= prescaler;
}

void setPWM2A(uint8_t ciclo){
	OCR2A = ciclo;
}

void setPWM2B(uint8_t ciclo){
	OCR2B = ciclo;
}