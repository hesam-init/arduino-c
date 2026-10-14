# Arduino Blink PureC

This is the source code of my blog article: https://www.tderflinger.com/en/arduino-blinking-led-pure-c

![Arduino Uno Blink LED](./projects/blink-led/wiring.png)

Arduino Uno programs written in pure C (avr-gcc + avrdude, no Arduino IDE).

## Projects

Each project lives in its own folder under `projects/` with its source, a
[Wokwi](https://wokwi.com) `diagram.json` describing the wiring, and a `wiring.png`
generated from it.

| Project | Description |
| --- | --- |
| [blink-led](./projects/blink-led/) | Blink an LED on pin 13 every 2 seconds |

For this to compile and load to the Arduino Uno you need
the AVR C compiler and Avrdude.

## Installation

Install the AVR toolchain for your Linux distribution:

- [Debian-based (Debian, Ubuntu, Mint, ...)](./wiki/install-debian.md)
- [Arch-based (Arch, Manjaro, EndeavourOS, ...)](./wiki/install-arch.md)

## Compiling

Pick the project with `PROJECT` (default: `blink-led`). All build output
(`.o`, `.elf`, `.hex`) goes into `build/<project>/`:

```bash
make                     # build build/blink-led/main.hex and print the size report
make PROJECT=blink-led   # same, naming the project explicitly
make size                # print the size report again
make clean               # remove the build/ directory
```

## Wiring diagrams

The wiring of each project is described in `projects/<project>/diagram.json`
([Wokwi diagram format](https://docs.wokwi.com/diagram-format)) and rendered to
`wiring.png` with [@wokwi/elements](https://github.com/wokwi/wokwi-elements) in headless Chrome.
This needs Node.js and Google Chrome (set `CHROME=/path/to/chrome` to use another one).
The first run installs the renderer's npm packages.

```bash
make diagram                 # render projects/blink-led/wiring.png
make diagram PROJECT=...     # render another project
make diagrams                # render every project
```

A diagram lists the parts and the wires between their pins:

```json
{
  "parts": [
    { "type": "wokwi-arduino-uno", "id": "uno", "top": 0, "left": 0 },
    { "type": "wokwi-led", "id": "led1", "top": -80, "left": 100, "attrs": { "color": "red" } }
  ],
  "connections": [
    [ "led1:A", "uno:13", "green", [] ],
    [ "led1:C", "uno:GND.1", "black", [] ]
  ]
}
```

- `top`/`left` are in pixels; parts can also have `"rotate": 90`.
- A wire's route uses `vN`/`hN` to move N px vertically/horizontally. Moves before `"*"`
  start at the first pin, moves after it lead into the second pin.
- Any part from [@wokwi/elements](https://elements.wokwi.com) works (LEDs, resistors, buttons,
  displays, sensors, ...). The renderer prints the valid pin names if you get one wrong.
  Breadboards are not part of that library, so the renderer can't draw them yet.

The easiest way to place parts is to edit the diagram on [wokwi.com](https://wokwi.com)
(new Arduino Uno project → `diagram.json` tab), then copy it back.

## Simulating

The same `diagram.json` runs your compiled `.hex` in the Wokwi simulator: build the
project, then open `projects/<project>/` in VS Code with the
[Wokwi extension](https://docs.wokwi.com/vscode/getting-started) (it reads `wokwi.toml`)
and run **Wokwi: Start Simulator**.

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
