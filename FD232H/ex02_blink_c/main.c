#include <libftdi1/ftdi.h>
#include <unistd.h>

int main() {
    struct ftdi_context ftdi;
    ftdi_init(&ftdi);
    ftdi_usb_open(&ftdi, 0x0403, 0x6014);
    ftdi_set_bitmode(&ftdi, 0x01, BITMODE_BITBANG);

    while(1) {
        ftdi_write_data(&ftdi, (unsigned char[]){0x01}, 1);
        usleep(500000);
        ftdi_write_data(&ftdi, (unsigned char[]){0x00}, 1);
        usleep(500000);
    }

    ftdi_usb_close(&ftdi);
    ftdi_deinit(&ftdi);
}
