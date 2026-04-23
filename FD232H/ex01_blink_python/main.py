from pyftdi.gpio import GpioAsyncController
import time

gpio = GpioAsyncController()
gpio.configure('ftdi://ftdi:232h:FT8JHZCH/1', direction=0x01)  # pin AD0 output

try:
    while True:
        gpio.write(0x01)   # AD0 HIGH
        time.sleep(0.5)
        gpio.write(0x00)   # AD1 LOW
        time.sleep(0.5)
except KeyboardInterrupt:
    gpio.write(0x00)
    gpio.close()
