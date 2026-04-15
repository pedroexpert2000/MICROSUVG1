/*
 * PRE_LAB_2.c
 *
 * Created: 13/04/2026 11:35:00
 * Author : Pedro Porras
 */ 

#define F_CPU 1600000
#include <avr/io.h>
#include <util/delay.h>

/****************************************/
// Encabezado (Libraries)

#include "ADC.h"
#include "PWM1.h"
void setup();

/****************************************/
// Main Function

int main(void)
{
    setup();
    initPWM1(PWM1A_NO_INVERTIDO, PWM1B_NO_INVERTIDO, ICR1_A, ICR1_B, PWM_PR_8, 39999);
    initADC(ADC_AVCC, ADCH_ACT, PS_8);
    while (1)
    {
        uint8_t pot1, pot2;
        uint16_t pwm_servo1, pwm_servo2;

        pot1 = readADC(0);
        pot2 = readADC(1);

        pwm_servo1 = 1000 + (((uint32_t)pot1 * 1000) / 255);
        setPWM1A(pwm_servo1);
        
        pwm_servo2 = 1000 + (((uint32_t)pot2 * 1000) / 255);
        setPWM1B(pwm_servo2);
		
		_delay_ms(20);
    }
}

/****************************************/
// NON-Interrupt subroutines

void setup(){
	
	DDRC &= ~((1<<DDC0) | (1<<DDC1));
}