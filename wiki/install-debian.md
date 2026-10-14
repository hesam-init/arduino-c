# Installation on Debian-based Distros

For Debian, Ubuntu, Linux Mint and other Debian-based distributions.

## Install the toolchain

```bash
sudo apt-get update && sudo apt-get install gcc-avr binutils-avr gdb-avr avr-libc avrdude make
```

## Serial port access

To upload without `sudo`, add your user to the `dialout` group, then log out and back in:

```bash
sudo usermod -aG dialout $USER
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
