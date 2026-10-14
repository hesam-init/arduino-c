# Arduino Blink PureC

This is the source code of my blog article: https://www.tderflinger.com/en/arduino-blinking-led-pure-c

![Arduino Uno Blink LED](./BlinkLed.png)

This is an Arduino sketch implemented as pure C.

For this to compile and load to the Arduino Uno you need
the AVR C compiler and Avrdude.

## Installation

Install the AVR toolchain for your Linux distribution:

- [Debian-based (Debian, Ubuntu, Mint, ...)](./wiki/install-debian.md)
- [Arch-based (Arch, Manjaro, EndeavourOS, ...)](./wiki/install-arch.md)

## Compiling

To compile the led program, run make. All build output (`.o`, `.elf`, `.hex`)
goes into the `build/` directory:

```bash
make        # build build/led.hex and print the size report
make size   # print the size report again
make clean  # remove the build/ directory
```

## Deploying to Arduino Uno

In order to upload the binary to your Arduino Uno, check on which port
your Arduino is connected. You can see the path for example in the Arduino IDE.
Either change the default value in the Makefile (`PORT`) or pass it on the command line.

Then you can upload the program via:

```bash
make upload                     # or: make deploy
make upload PORT=/dev/ttyACM0
```

## USB keyboard mode

The Uno R3 can be turned into a USB keyboard by reflashing its ATmega16U2 USB chip.
See [Making the Uno a USB keyboard](./wiki/usb-keyboard.md).

## Restoring the default USB-serial firmware

To turn the board back into a normal Uno, put the 16U2 in DFU mode again ([how](./wiki/usb-keyboard.md#2-put-the-16u2-in-dfu-mode)) and run:

```bash
sudo make restore-usbserial
```

This flashes the stock firmware from `firmware/Arduino-usbserial-atmega16u2-Uno-Rev3.hex`,
taken from [ArduinoCore-avr](https://github.com/arduino/ArduinoCore-avr/tree/master/firmwares/atmegaxxu2/arduino-usbserial).
After a replug, the board shows up as `2341:0043` on `/dev/ttyACM0` again, and `make upload` works.
The 16U2's DFU bootloader is write-protected, so this always works.

## References

- https://github.com/sagarsp/arduino-blink-c

## License

MIT License
