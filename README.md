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

## References

- https://github.com/sagarsp/arduino-blink-c

## License

MIT License
