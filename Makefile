# Change these values accordingly, or override them on the command line:
#   make upload PORT=/dev/ttyACM0
#   make PROJECT=blink-led
PROJECT    ?= blink-led
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

SRC_DIR = projects/$(PROJECT)
OUT_DIR = $(BUILD_DIR)/$(PROJECT)

SRC = $(wildcard $(SRC_DIR)/*.c)
OBJ = $(patsubst $(SRC_DIR)/%.c,$(OUT_DIR)/%.o,$(SRC))
ELF = $(OUT_DIR)/main.elf
HEX = $(OUT_DIR)/main.hex

RENDER_DIR = tools/render-diagram
RENDER     = node $(RENDER_DIR)/render.mjs

.PHONY: all upload deploy size clean restore-usbserial diagram diagrams

all: $(HEX)

$(OUT_DIR):
	mkdir -p $@

$(OUT_DIR)/%.o: $(SRC_DIR)/%.c | $(OUT_DIR)
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

# Render the wiring picture of a project from its Wokwi diagram.json
diagram: | $(RENDER_DIR)/node_modules
	$(RENDER) $(SRC_DIR)/diagram.json $(SRC_DIR)/wiring.png

# Render the wiring pictures of all projects
diagrams: | $(RENDER_DIR)/node_modules
	for d in projects/*/diagram.json; do \
		$(RENDER) $$d $$(dirname $$d)/wiring.png || exit 1; \
	done

$(RENDER_DIR)/node_modules: $(RENDER_DIR)/package-lock.json
	cd $(RENDER_DIR) && npm ci
	touch $@

clean:
	rm -rf $(BUILD_DIR)
