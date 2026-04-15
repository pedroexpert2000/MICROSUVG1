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

// Macros de Referencia de Voltaje
#define ADC_AREF 0x00
#define ADC_AVCC (1<<REFS0)
#define ADC_INT  (1<<REFS1)|(1<<REFS0)

// Macros de Justificación
#define ADCH_ACT (1<<ADLAR) 

// Macros de Prescaler
#define PS_2   (1<<ADPS0)
#define PS_4   (1<<ADPS1)
#define PS_8   (1<<ADPS1)|(1<<ADPS0)
#define PS_16  (1<<ADPS2)
#define PS_32  (1<<ADPS2)|(1<<ADPS0)
#define PS_64  (1<<ADPS2)|(1<<ADPS1)
#define PS_128 (1<<ADPS2)|(1<<ADPS1)|(1<<ADPS0)


void initADC(uint8_t voltage, uint8_t HIGH_LOW, uint8_t prescaler);
uint8_t readADC(uint8_t canal);

#endif /* ADC_H_ */