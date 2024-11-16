
FIRMWARE_FILES = $(wildcard *.c)
PYTHON = python3

GCC_WARNS  = -Werror -Wall -Wextra -Wshadow -Wundef -Wpointer-arith -Wcast-qual -Wcast-align -Wwrite-strings
TOOLCHAIN_PREFIX = riscv32-unknown-elf-

BUILD_DIR = build

all: $(BUILD_DIR)/firmware.hex

$(BUILD_DIR)/firmware.hex: $(BUILD_DIR)/firmware.bin makehex.py
	$(PYTHON) makehex.py $(BUILD_DIR)/firmware.bin 4096 > $(BUILD_DIR)/firmware.hex

$(BUILD_DIR)/firmware.bin: $(BUILD_DIR)/firmware.elf
	$(TOOLCHAIN_PREFIX)objcopy -O binary $< $@
	chmod -x $@

$(BUILD_DIR)/firmware.elf: $(FIRMWARE_FILES) $(BUILD_DIR)/start.o
	$(TOOLCHAIN_PREFIX)gcc -O0 -mabi=ilp32 -march=rv32i -ffreestanding -nostdlib -o $@ \
		-Wl,--build-id=none,-Bstatic,-Triscv.ld,-Map,$(BUILD_DIR)/firmware.map,--strip-debug \
		$(BUILD_DIR)/start.o $(FIRMWARE_FILES) -lgcc
	chmod -x $@
	$(TOOLCHAIN_PREFIX)objdump --disassemble-all $@ >> $(BUILD_DIR)/firmware.txt

$(BUILD_DIR)/start.o: start.S $(BUILD_DIR)
	$(TOOLCHAIN_PREFIX)gcc -c -mabi=ilp32 -march=rv32i -o $@ $<

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

clean:
	rm -vrf $(BUILD_DIR)

