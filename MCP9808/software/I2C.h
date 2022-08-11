
/*********************************************************/
// bit1 scl   bit0 SDA

void attente(unsigned x);

void start_i2c();

void stop_i2c();

char write_i2c(unsigned char x);

unsigned char read_i2c(char ack);
