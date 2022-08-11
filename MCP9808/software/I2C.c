#include "montimer.h"

#define I2C  *((volatile unsigned char *)0x80021040)
/*********************************************************/
// bit1 scl   bit0 SDA

void attente(unsigned x){  // x et un mltiple de 20 ns
		unsigned v1,v2;
		v1= getsnap();
		do {
			//	v2= getsnap();
		} while(getsnapdif(v1,getsnap())<x); //  x*20ns = temps d'attente

}

void start_i2c(){
		I2C = 3;
		attente(20); //2µs
		I2C = 2;
		attente(20); //1µs
		I2C = 0;
		attente(20); //1µs
}
void stop_i2c(){
		I2C = 0; //assurer 0 sur SDA et SCL
		attente(20);
		I2C= 2; // mettre SCL a 1
		attente(20);
		I2C= 3;
		attente(20); //2µs
}

char write_i2c(unsigned char x){
		unsigned short i;
		char bit,ack;

		for(i=0; i<8; i++){
		    bit=((x&0x80) ? 1 : 0);
				I2C = bit;
				attente(10);
				I2C = 2| bit;
				x=x<<1;
				attente(1);
				I2C = bit;
				attente(10);
		}
		I2C=1; // bit ACK
		attente(1);
		I2C=3;
		attente(1);
		ack = I2C&0x01;
		attente(1);
		I2C=01;
		attente(1);
		return ack;
}

unsigned char read_i2c(char ack){
		unsigned short i;
		unsigned char x;
		for(i=0; i<8; i++){
				I2C = 3;
				attente(1);
				x=x<<1;
				x= x| (I2C&0x01);
				attente(1);
				I2C= 01;
				attente(1);
		}
		I2C=(ack&1); // bit ACK
		attente(1);
		I2C= 2 |  (ack&1);
		attente(1);
		I2C =(ack&1);
		attente(1);
		I2C = 01;
		return x;
}
