/*
 * ADC.h
 *
 * Created: 13/04/2026 20:25:24
 *  Author: Pedro Porras
 */ 


#ifndef ADC_H_
#define ADC_H_

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

#define PS_2        (1<<ADPS0)
#define PS_4        (1<<ADPS1)
#define PS_8        (1<<ADPS1)|(1<<ADPS0)
#define PS_16       (1<<ADPS2)
#define PS_32       (1<<ADPS2)|(1<<ADPS0)
#define PS_64       (1<<ADPS2)|(1<<ADPS1)
#define PS_128      (1<<ADPS2)|(1<<ADPS1)|(1<<ADPS0) 


void initADC(uint8_t voltage, uint8_t HIGH_LOW, uint8_t prescaler);
uint16_t readADC(uint8_t canal);

#endif /* ADC_H_ */