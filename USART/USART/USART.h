/*
 * USART.h
 *
 * Created: 20/04/2026 11:43:53
 *  Author: Pedro Porras
 */ 


#include <avr/io.h>
#include <stdint.h>

#ifndef USART_H_
#define USART_H_

// UCSRNA: Control and Status Register n A
#define RECEIVE_COMPLETE        (1<<RXC0)
#define TRANSMIT_COMPLETE       (1<<TXC0)
#define DATA_REGISTER_EMPTY     (1<<UDRE0)

#define FRAME_ERROR             (1<<FE0)
#define DATA_OVERUN             (1<<DOR0)
#define USART_PARITY_ERROR      (1<<UPE0)

#define DOUBLE_SPEED            (1<<U2X0)
#define MULTI_COMMUNICATION     (1<<MPCM0)

// UCSRNB: Control and Status Register n B
#define RX_INTERRUPT            (1<<RXCIE0)
#define TX_INTERRUPT            (1<<TXCIE0)
#define DR_INTERRUPT            (1<<UDRIE0)

#define RECEIVER_ENABLE         (1<<RXEN0)
#define TRANSMITTER_ENABLE      (1<<TXEN0)
#define CHARACTER_SIZE_9BIT     (1<<UCSZ02) 

#define RECEIVE_DATA            (1<<RXB80)
#define TRANSMIT_DATA           (1<<TXB80)

// UCSRNC: Control and Status Register n C 

#define ASYNCHRONOUS_MODE       (0<<UMSEL00)
#define SYNCHRONOUS_MODE        (1<<UMSEL00)

#define PARITY_NONE             (0<<UPM00)
#define PARITY_EVEN             (1<<UPM01)
#define PARITY_ODD              (1<<UPM01)|(1<<UPM00)

#define STOP_BIT_1              (0<<USBS0)
#define STOP_BIT_2              (1<<USBS0)

#define CHAR_SIZE_5             (0<<UCSZ00)
#define CHAR_SIZE_6             (1<<UCSZ00)
#define CHAR_SIZE_7             (1<<UCSZ01)
#define CHAR_SIZE_8             (1<<UCSZ01)|(1<<UCSZ00) 


void initUSART(uint8_t config_A, uint8_t config_B, uint8_t config_C, uint8_t modo,  uint8_t stopbit, uint8_t charsize, uint32_t baud);
void writeChar(char c);
void writeString(char* string);

#endif /* USART_H_ */