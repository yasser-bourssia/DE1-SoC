
#include <stdio.h>
#include <stdlib.h>
#include "NIOS2_CTRL_REG_MACRO.h"
#include "montimer.h"

// constante des l'adresse des periphériques

/*#define HEX  *((volatile unsigned int *) ????????????)
#define LEDR  *((volatile unsigned char *) ???????????)
#define SW   *((volatile unsigned char *) ???????????)
#define LEDG  *((volatile unsigned char *) ???????????)
*/


///////////////////////////////////////////////////////////////
/******************************************************/
//   Declaration des variables globales
/******************************************************/

long v1, v2;
unsigned char xout=0, xin;
unsigned char clv, touche;
unsigned int j,k=0;

char TAB[16]={0xd7,0xee,0xde,0xbe,0xed,0xdd,0xbd,0xeb,0xdb,0xbb,0x7e,0x7d,0x7b,0x77,0xe7,0xb7};

unsigned char tabuart[10]={0xFF, 0x77, 0x00, 0x96, 0x00, 0x96, 0x00, 50, 0xff, 0xff};
char *buffer;

char flag250=0;
unsigned int cpt=0;

char ack;
unsigned char temph,templ;
int temperature;

/**************************************************/
/* Interrupt routine TIMER2												*/
/**************************************************/
int Timer2_irq(void)
{
// ici on mettre le code de la routine d'interruption
			flag250 =1;
}

/******************************************************/
// fonction init Timer2 et son interruption
/******************************************************/
void init_IT(){
														// base du TIMER2
	volatile int *Timer_ptr2 = (int *) 0x80021020; // interval timer2 base address
	// inserer dans counter la valeur de la période
	// exprimée en multiple de 20ns
	int counter =  12500000; //  multiple de 1/(50 MHz)
	*(Timer_ptr2 + 0x2) = (counter & 0xFFFF);
	*(Timer_ptr2 + 0x3) = (counter >> 16) & 0xFFFF;
	/* start interval timer, enable its interrupts */
	*(Timer_ptr2 + 1) = 0x7; // STOP = 0, START = 1, CONT = 1, ITO = 1
	/* set  mask bits to 1 (bit 0 is Nios II reset) */
	NIOS2_WRITE_IENABLE( 0x10 ); /* set interrupt mask bits for Timer2 bit4*/
	NIOS2_WRITE_STATUS( 1 ); // enable Nios II interrupts
}

///////////////////////////////////////////////////////////////





////////////////////////////////////////////////////////////////



int main(){
	getperiod();
	start_timer();
	init_IT(); // initialise les interruptions du TIMER2

	v1 = getsnap();


	while(1){





					if(flag250==1){
									flag250=0;
									cpt++;




					}



					if(cpt>4) {
										cpt=0;
											start_i2c();
											ack = write_i2c(0x30);
											ack = write_i2c(0x05);
											stop_i2c();
											start_i2c();
											ack = write_i2c(0x31);
											temph = read_i2c(0);
											templ = read_i2c(1);
											stop_i2c;
											temperature= ((temph&0x0F)<<8)|(0xFF&templ);
											temperature = ((0xF&temperature)*100)/16 + (temperature>>4)*100;
											sprint(buffer,"%u \n",temperature);
											puts(buffer);



					}


			}
  }

