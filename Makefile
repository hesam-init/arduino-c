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

CC      = avr-gcc
OBJCOPY = avr-objcopy
SIZE    = avr-size
AVRDUDE = avrdude

CFLAGS  ?= -Wall -Os -mmcu=$(DEVICE) -DF_CPU=$(F_CPU)
LDFLAGS ?= -mmcu=$(DEVICE)

OBJ = $(BUILD_DIR)/$(FILENAME).o
ELF = $(BUILD_DIR)/$(FILENAME).elf
HEX = $(BUILD_DIR)/$(FILENAME).hex

.PHONY: all upload deploy size clean

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

clean:
	rm -rf $(BUILD_DIR)
