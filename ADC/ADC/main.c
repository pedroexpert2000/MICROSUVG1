/*
 * ADC.c
 *
 * Created: 13/04/2026 20:24:50
 * Author : Pedro Porras
 */ 

#include <avr/io.h>
#include <stdint.h>

#define ADC_AVCC        (1<<REFS0)
#define ADC_RESERVED    (1<<REFS1)
#define ADC_INTERNAL    (1<<REFS0)|(1<<REFS1)

//CONTROL 
#define ADC_ENABLE      (1<<ADEN)
#define ADC_START       (1<<ADSC)
#define ADC_AUTO        (1<<ADATE)

#define ADC_FLAG        (1<<ADIF)
#define ADC_INT_ENABLE  (1<<ADIE)
#define ADCH_ACT        (1<<ADLAR)
        

#define ADC_PS_2        (1<<ADPS0)
#define ADC_PS_4        (1<<ADPS1)
#define ADC_PS_8        (1<<ADPS1)|(1<<ADPS0)
#define ADC_PS_16       (1<<ADPS2)
#define ADC_PS_32       (1<<ADPS2)|(1<<ADPS0)
#define ADC_PS_64       (1<<ADPS2)|(1<<ADPS1)
#define ADC_PS_128      (1<<ADPS2)|(1<<ADPS1)|(1<<ADPS0)


/**************************************************************/


# define F_CPU 16000000


int main()
{
    /* Replace with your application code */
    while (1) 
    {
    }
}


void initADC(uint8_t voltage, uint8_t HIGH_LOW, uint8_t control, uint8_t prescaler){

	ADMUX = 0;
	ADMUX |= voltage | HIGH_LOW;

	ADCSRA = 0;
	ADCSRA |= ADC_ENABLE | control | prescaler;
}