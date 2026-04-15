/*
	* PMW0.h
	*
	* Created: 13/04/2026 19:24:43
	*  Author: Pedro Porras
	*/ 


#ifndef PMW0_H_
#define PMW0_H_

#include <avr/io.h>
#include <stdint.h>

#define PWM0A_NO_INVERTIDO   (1<<COM0A1)
#define PWM0A_INVERTIDO      (1<<COM0A1)|(1<<COM0A0)

#define PWM0B_NO_INVERTIDO   (1<<COM0B1)
#define PWM0B_INVERTIDO      (1<<COM0B1)|(1<<COM0B0)

#define PWM_FAST_MODE        (1<<WGM01)|(1<<WGM00)
#define PWM_PHASE_CORRECT    (1<<WGM00)

#define PWM_PR_1      (1<<CS00)
#define PWM_PR_8      (1<<CS01)
#define PWM_PR_64     (1<<CS01)|(1<<CS00)
#define PWM_PR_256    (1<<CS02)
#define PWM_PR_1024   (1<<CS02)|(1<<CS00)


void initPWM0(uint8_t config_A, uint8_t config_B, uint8_t PWM_MODE, uint8_t prescaler);
void setPWM0A(uint8_t ciclo);
void setPWM0B(uint8_t ciclo);

#endif /* PMW0_H_ */