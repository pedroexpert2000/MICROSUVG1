/*
 * PRE_LAB_2.c
 *
 * Created: 13/04/2026 11:35:00
 * Author : Pedro Porras
 */ 

#define F_CPU 16000000
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>

/****************************************/
// Encabezado (Libraries)

#include "ADC.h"
#include "PWM1.h"
#include "PWM2.h"
void  setup();

volatile uint8_t pwm_led_register;
volatile uint8_t pwm_cont; 


/****************************************/
// Main Function

int main(void)
{
    setup();
    initPWM1(PWM1A_NO_INVERTIDO, 0 , ICR1_A, ICR1_B, PWM_PR_8, 39999);
	initPWM2(PWM2A_NO_INVERTIDO, 0, PWM2_FAST_MODE, PWM2_PR_1024);
    initADC(ADC_AVCC, ADCH_ACT, PS_8);
	sei();
    while (1)
   {
	   uint8_t pot1, pot2, pot3;
	   uint16_t pwm_servo1;
	   uint8_t pwm_servo2;
	  
	   readADC(0);        
	   pot1 = readADC(0);  

	   readADC(1);         
	   pot2 = readADC(1); 

	   readADC(2);         
	   pot3 = readADC(2);

	   pwm_servo1 =  1500 + (((uint32_t)pot1 * 3735) / 255);
	   setPWM1A(pwm_servo1);
	   
	   pwm_servo2 = 8 + (((uint16_t)pot2 * 31) / 255);
	   setPWM2A(pwm_servo2);
	   
	  
	   pwm_led_register = pot3;
	   
	   _delay_ms(20);
   }
}

/****************************************/
// NON-Interrupt subroutines

void setup(){
	
	DDRC &= ~((1<<DDC0) | (1<<DDC1) | (1<<DDC2));
	
	DDRD   |= (1<<DDD2);
	TCCR0A = 0;
	TCCR0B = 0;
	TIMSK0 |= (1<<TOIE0); // Habilitar interrupción por Overflow
	TCCR0B |= (1<<CS00);  // Prescaler de 1 
}

ISR(TIMER0_OVF_vect){
	pwm_cont++;       // Contador 
	
	if (pwm_cont < pwm_led_register) {
		PORTD |= (1<<PORTD2);  // Enciende el LED en PD2
		} else {
		PORTD &= ~(1<<PORTD2); // Apaga el LED en PD2
	}
}