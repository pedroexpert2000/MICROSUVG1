/*
 * PWM1.h
 *
 * Created: 13/04/2026 22:25:58
 * Author: Pedro Porras
 */ 

#ifndef PWM1_H_
#define PWM1_H_

#include <avr/io.h>
#include <stdint.h>

// Modos de salida (COM)
#define PWM1A_NO_INVERTIDO   (1<<COM1A1)
#define PWM1A_INVERTIDO      (1<<COM1A1)|(1<<COM1A0)

#define PWM1B_NO_INVERTIDO   (1<<COM1B1)
#define PWM1B_INVERTIDO      (1<<COM1B1)|(1<<COM1B0)

// Modos de generación de onda (WGM) 
#define PWM_FAST_MODE_8BIT   (1<<WGM10)
#define PWM_FAST_MODE_9BIT   (1<<WGM11)
#define PWM_FAST_MODE_10BIT  (1<<WGM11)|(1<<WGM10)

#define PWM_PHASE_CORRECT_8BIT    (1<<WGM10)
#define PWM_PHASE_CORRECT_9BIT    (1<<WGM11)
#define PWM_PHASE_CORRECT_10BIT   (1<<WGM10)|(1<<WGM11)

// VAL comparacion 
#define ICR1_A			    (1<<WGM11)
#define ICR1_B			 	(1<<WGM13)|(1<<WGM12)

#define PWM_WGM12           (1<<WGM12)

// Prescalers 
#define PWM_PR_1      (1<<CS10)
#define PWM_PR_8      (1<<CS11)
#define PWM_PR_64     (1<<CS11)|(1<<CS10)
#define PWM_PR_256    (1<<CS12)
#define PWM_PR_1024   (1<<CS12)|(1<<CS10)


void initPWM1(uint8_t config_A, uint8_t config_B, uint8_t PWM_MODE_A, uint8_t PWM_MODE_B, uint8_t prescaler, uint16_t num_comp);
void setPWM1A(uint16_t ciclo);
void setPWM1B(uint16_t ciclo);

#endif /* PWM1_H_ */