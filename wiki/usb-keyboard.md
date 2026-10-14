# Making the Uno a USB keyboard

The Uno R3's ATmega328P has no USB hardware, but the board's USB-serial chip,
the **ATmega16U2**, does. Reflashing the 16U2 with a
[LUFA](https://github.com/abcminiuser/lufa) HID keyboard firmware makes the board
show up as a normal USB keyboard on any computer, without a host program.
This repo doesn't contain that firmware anymore. These are the steps to rebuild it.

## 1. Build the keyboard firmware

1. Add LUFA: `git submodule add https://github.com/abcminiuser/lufa lib/lufa`,
   then `git -C lib/lufa checkout LUFA-210130`.
2. Copy `lib/lufa/Demos/Device/ClassDriver/Keyboard` into `keyboard/` and edit its `makefile`:

   ```make
   MCU       = atmega16u2
   BOARD     = UNO
   F_CPU     = 16000000
   LUFA_PATH = ../lib/lufa/LUFA
   ```

   You can drop the `cppcheck`, `doxygen`, `dfu`, `hid`, `avrdude` and `atprogram` includes.
3. In `Keyboard.c`, remove the Joystick/Buttons code and do the key logic in the
   1 ms USB Start-Of-Frame event instead:

   ```c
   static volatile uint16_t ms_counter;
   static volatile bool send_enter;

   void EVENT_USB_Device_StartOfFrame(void)
   {
     HID_Device_MillisecondElapsed(&Keyboard_HID_Interface);
     if (++ms_counter >= 2000) {
       ms_counter = 0;
       send_enter = true;
     }
   }

   // in CALLBACK_HID_Device_CreateHIDReport (LUFA zeroes the report first,
   // so the next report releases the key):
   if (send_enter) {
     send_enter = false;
     KeyboardReport->KeyCode[0] = HID_KEYBOARD_SC_ENTER;
   }
   ```

4. Run `make -C keyboard`. The result is `keyboard/keyboard.hex`, about 4 KB.

## 2. Put the 16U2 in DFU mode

Install `dfu-programmer` (`sudo pacman -S dfu-programmer`, or `sudo apt install dfu-programmer`).
With the board plugged in, briefly short the two pins of the small 6-pin ICSP
header next to the USB jack, the ones closest to the jack (16U2 RESET and GND).
`lsusb` should now show `03eb:2fef Atmel Corp. atmega16u2 DFU bootloader`.

## 3. Flash it

```bash
sudo dfu-programmer atmega16u2 erase --force --debug 20
sudo dfu-programmer atmega16u2 flash keyboard/keyboard.hex
sudo dfu-programmer atmega16u2 launch
```

Use `--force` on `erase`. With dfu-programmer 1.1, a plain `erase` fails its
blank check on this chip with error 5. `--debug 20` prints what it is doing.

Unplug and replug the board. It shows up as a keyboard (`03eb:2042`) and
presses Enter every 2 seconds into whatever window has focus. Unplug it to stop.
While it is in keyboard mode, `make upload` doesn't work.

## Going back

To restore the stock Arduino USB-serial firmware, put the 16U2 in DFU mode again and run
`sudo make restore-usbserial` from the repo root. See [Restoring the default USB-serial firmware](../README.md#restoring-the-default-usb-serial-firmware).
