# Change these values accordingly, or override them on the command line:
#   make upload PORT=/dev/ttyACM0
FILENAME   ?= led
DEVICE     ?= atmega328p
F_CPU      ?= 16000000UL
# Path where your Arduino Uno is connected to
PORT       ?= /dev/ttyUSB0
PROGRAMMER ?= arduino
BAUD       ?= 115200
BUILD_DIR  ?= build
DFU        ?= dfu-programmer

CC      = avr-gcc
OBJCOPY = avr-objcopy
SIZE    = avr-size
AVRDUDE = avrdude

CFLAGS  ?= -Wall -Os -mmcu=$(DEVICE) -DF_CPU=$(F_CPU)
LDFLAGS ?= -mmcu=$(DEVICE)

OBJ = $(BUILD_DIR)/$(FILENAME).o
ELF = $(BUILD_DIR)/$(FILENAME).elf
HEX = $(BUILD_DIR)/$(FILENAME).hex

.PHONY: all upload deploy size clean restore-usbserial

all: $(HEX)

$(BUILD_DIR):
	mkdir -p $@

$(BUILD_DIR)/%.o: %.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c -o $@ $<

$(ELF): $(OBJ)
	$(CC) $(LDFLAGS) -o $@ $^

$(HEX): $(ELF)
	$(OBJCOPY) -j .text -j .data -O ihex $< $@
	$(SIZE) --format=avr --mcu=$(DEVICE) $<

upload: $(HEX)
	$(AVRDUDE) -v -p $(DEVICE) -c $(PROGRAMMER) -P $(PORT) -b $(BAUD) -U flash:w:$(HEX):i

deploy: upload

size: $(ELF)
	$(SIZE) --format=avr --mcu=$(DEVICE) $<

# Put the stock Arduino USB-serial firmware back so `make upload` works again
# (the Uno's ATmega16U2 must be in DFU mode)
restore-usbserial:
	$(DFU) atmega16u2 erase --force
	$(DFU) atmega16u2 flash firmware/Arduino-usbserial-atmega16u2-Uno-Rev3.hex
	$(DFU) atmega16u2 launch

clean:
	rm -rf $(BUILD_DIR)
