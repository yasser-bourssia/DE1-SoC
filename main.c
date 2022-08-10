#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>

#define GIO7_ADDR  ((volatile unsigned int *)0xFFD0849C)
#define GIO8_ADDR  ((volatile unsigned int *)0xFFD084A0)
#define MUX5_ADDR  ((volatile unsigned int *)0xFFD086B0)
#define MUX6_ADDR  ((volatile unsigned int *)0xFFD086B4)
#define I2C0FPGA_ADDR  ((volatile unsigned int *)0xFFD08704)
#define I2C_con ((volatile unsigned int *) (0xFFC04000)) // OFFSETS
#define I2C_tar ((volatile unsigned int *) (0xFFC04000 + 0x4))
#define I2C_data_cmd ((volatile unsigned int *) (0xFFC04000 + 0x10))
#define I2C_hcnt ((volatile unsigned int *) (0xFFC04000 + 0x1C))
#define I2C_lcnt ((volatile unsigned int *) (0xFFC04000 + 0x20))
#define I2C_clrint ((volatile unsigned int *) (0xFFC04000 + 0x40))
#define I2C_enable ((volatile unsigned int *) (0xFFC04000 + 0x6C))
#define I2C_tx ((volatile unsigned int *) (0xFFC04000 + 0x74))
#define I2C_rx ((volatile unsigned int *) (0xFFC04000 + 0x78))
#define I2C_en ((volatile unsigned int *) (0xFFC04000 + 0x9C))

#define ADXL345_DEVID				0x00
#define ADXL345_BW_RATE				0x2C
#define ADXL345_POWER_CTL			0x2D
#define ADXL345_THRESH_ACT			0x24
#define ADXL345_THRESH_INACT		0x25
#define ADXL345_TIME_INACT			0x26
#define ADXL345_ACT_INACT_CTL		0x27
#define ADXL345_INT_ENABLE			0x2E
#define ADXL345_INT_SOURCE			0x30
#define ADXL345_DATA_FORMAT			0x31
#define ADXL345_ACTIVITY			0x10
#define ADXL345_DATAREADY 			0x80
#define ADXL345_OFSX                0x1E
#define ADXL345_OFSY                0x1F
#define ADXL345_OFSZ                0x20

#define BUTTONS_ADDR                ((volatile short *)0xFF200050)

void config_pinmux();

void i2c_initiateConfig();

void i2c_READ(uint8_t address, uint8_t *value);

void i2c_WRITE(uint8_t address, uint8_t value);

void ACC_init();

void mult_READ(uint8_t address, uint8_t values[], uint8_t len);

void acceCalibrate();

int acc_dataR();

int main()
{

uint8_t devid;
uint8_t interrupts;





config_pinmux();
i2c_initiateConfig();
ACC_init();


i2c_READ(ADXL345_DEVID, &devid);


if (devid != 0xE5) {

    printf("Incorrect device ID \n");

    return -1;

}

uint8_t value[6];
short realX,realY,realZ;

//uint8_t id;

//i2c_READ(ADXL345_DEVID, &id);

int count = 0;

while(1){

realX = 0;
realY = 0;
realZ = 0;


if (count == 1e5) {


i2c_READ(ADXL345_INT_SOURCE, &interrupts);
//printf("The sensor is active \n");


if ((interrupts & 0x10) == 0) printf("Le capteur est inactif. \n");
else{
mult_READ(0x32, value, 6);

realX = value[0] | (short)(value[1] << 8);
realY = value[2] | (short)(value[3] << 8);
realZ = (value[4] | (short)(value[5] << 8)) - (pow(2,13)-1)/4;

printf("X : %d , Y : %d , Z : %d \n",realX, realY, realZ );

}



//if ((*BUTTONS_ADDR) & 0b1) acceCalibrate();





count=0;

}

count++;
}

return 0;

}




void config_pinmux(){

*GIO7_ADDR = 1;
*GIO8_ADDR = 1;
*I2C0FPGA_ADDR = 0;
}



void i2c_initiateConfig(){


*I2C_enable = 0x2;

while ((*(I2C_en) & 0x1) == 1 ) {}


*I2C_con = 0x65;

*I2C_tar = 0x53;


*I2C_hcnt = 60+30;
*I2C_lcnt = 130+30;

*I2C_enable = 0x1;

while ((*(I2C_en) & 0x1) == 0 ) {}


}

void i2c_READ(uint8_t address, uint8_t *value){



// Send reg address (+0x400 to send START signal)
*I2C_data_cmd= address + 0x400;

// Send read signal
*I2C_data_cmd = 0x100;

// Read the response (first wait until RX buffer contains data)
while (*I2C_rx == 0){}
*value = *I2C_data_cmd;


}

void i2c_WRITE(uint8_t address, uint8_t value){

 // Write value to internal register at address


 // Send reg address (+0x400 to send START signal)
 *I2C_data_cmd = address + 0x400;

 // Send value
 *I2C_data_cmd = value;

 }


 void ACC_init(){



i2c_WRITE(ADXL345_BW_RATE, 0x0A); // 100Hz sampling frequency

i2c_WRITE(ADXL345_DATA_FORMAT, 0x0F); // Full precision, left justified, full rate

i2c_WRITE(ADXL345_INT_ENABLE, 0x98); // Enable DATAREADY, ACT, INACT interrupts

i2c_WRITE(ADXL345_THRESH_ACT, 0x04); // 250mg == Activity threshold
i2c_WRITE(ADXL345_THRESH_INACT, 0xFF); // 125mg == Inactivity threshold

i2c_WRITE(ADXL345_TIME_INACT, 0x02);// 1s/LSB, 2 seconds!



i2c_WRITE(ADXL345_ACT_INACT_CTL, 0xFF); // Turn activity/inactivity, for all axes!


i2c_WRITE(ADXL345_POWER_CTL, 0x00); // Turn off for full reset

i2c_WRITE(ADXL345_POWER_CTL, 0x08); // Turn on

}

void mult_READ(uint8_t address, uint8_t values[], uint8_t len){

*I2C_data_cmd = address + 0x400;

int i;

for (i=0;i<len;i++)

    *I2C_data_cmd = 0x100;

int byte =0;

while (len){

        if ((*I2C_rx) > 0 ){
            values[byte] = *I2C_data_cmd;
            byte++;
            len--;
        }
}
}

void acceCalibrate(){


int offX=0, offY=0, offZ=0;

uint8_t valueC[6];

char ofx, ofy, ofz;

    i2c_READ(ADXL345_OFSX, (uint8_t *) &ofx);
	i2c_READ(ADXL345_OFSY, (uint8_t *) &ofy);
	i2c_READ(ADXL345_OFSZ, (uint8_t *) &ofz);




short i=0,valX,valY,valZ;

while (i < 32) {
    if(acc_dataR()){
    mult_READ(0x32, valueC, 6);

    valX = valueC[0] | (short)(valueC[1] << 8);
    valY = valueC[2] | (short)(valueC[3] << 8);
    valZ = valueC[4] | (short)(valueC[5] << 8);

    offX += valX;
    offY += valY;
    offZ += valZ;
    i++;
    }

}

offX = offX/32;
offY = offY/32;
offZ = offY/32;

offX = ofx - offX/4;

offY = ofy - offY/4;

offZ = ofz - offZ/4;

i2c_WRITE(ADXL345_OFSX, offX);
i2c_WRITE(ADXL345_OFSY, offY);
i2c_WRITE(ADXL345_OFSZ, offZ);




}

int acc_dataR(){

uint8_t data;

i2c_READ(ADXL345_INT_SOURCE, &data);


return((data & 0x80));



}
