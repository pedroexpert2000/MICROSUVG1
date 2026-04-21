/*
 * PWM2.h
 *
 * Arquitectura: 8 bits
 * Pines de Salida: D11 (PB3) para Canal A / D3 (PD3) para Canal B
 */ 

#ifndef PWM2_H_
#define PWM2_H_

#include <avr/io.h>
#include <stdint.h>


// Modos de salida (COM) para Timer 2
#define PWM2A_NO_INVERTIDO   (1<<COM2A1)
#define PWM2A_INVERTIDO      (1<<COM2A1)|(1<<COM2A0)

#define PWM2B_NO_INVERTIDO   (1<<COM2B1)
#define PWM2B_INVERTIDO      (1<<COM2B1)|(1<<COM2B0)

// Se configuran en TCCR2A
#define PWM2_FAST_MODE       (1<<WGM21)|(1<<WGM20)
#define PWM2_PHASE_CORRECT   (1<<WGM20)


// Prescalers únicos del Timer 2
#define PWM2_PR_1      (1<<CS20)
#define PWM2_PR_8      (1<<CS21)
#define PWM2_PR_32     (1<<CS21)|(1<<CS20)
#define PWM2_PR_64     (1<<CS22)
#define PWM2_PR_128    (1<<CS22)|(1<<CS20)
#define PWM2_PR_256    (1<<CS22)|(1<<CS21)
#define PWM2_PR_1024   (1<<CS22)|(1<<CS21)|(1<<CS20)


// Prototipos de funciones
void initPWM2(uint8_t config_A, uint8_t config_B, uint8_t PWM_MODE, uint8_t prescaler);
void setPWM2A(uint8_t ciclo);
void setPWM2B(uint8_t ciclo);


#endif /* PWM2_H_ */