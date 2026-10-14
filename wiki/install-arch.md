# Installation on Arch-based Distros

For Arch Linux, Manjaro, EndeavourOS and other Arch-based distributions.

## Install the toolchain

```bash
sudo pacman -Syu --needed avr-gcc avr-binutils avr-libc avr-gdb avrdude make
```

## Serial port access

To upload without `sudo`, add your user to the `uucp` group, then log out and back in:

```bash
sudo usermod -aG uucp $USER
```

## Verify

```bash
avr-gcc --version
avrdude -?
```

## Find the Arduino port

Plug in the board and run:

```bash
ls /dev/ttyUSB* /dev/ttyACM*
```

An official Arduino Uno usually shows up as `/dev/ttyACM0`, clones as `/dev/ttyUSB0`.
If it differs from the Makefile default (`/dev/ttyUSB0`), pass it when uploading:

```bash
make upload PORT=/dev/ttyACM0
```

```bash
sudo make upload PORT=/dev/ttyACM0
```

[Back to README](../README.md)
