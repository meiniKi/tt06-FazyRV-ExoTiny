
MAKE = make

YOSYS := yosys
NEXTPNR_ICE40 := nextpnr-ice40
ICEPACK := icepack

FIRMWARE 	= ../FazyRV-ExoTiny/sim/firmware/rom.hex
ICO_PCF		= ./ice40/icoboard.pcf

BUILD_DIR = ./build
ICO_SYNTH_FILE = $(BUILD_DIR)/ico_synth.json
ICO_ASC_FILE = $(BUILD_DIR)/ico_impl.asc
ICO_BIN_FILE = $(BUILD_DIR)/ico.bin

validation.icoboard: $(FIRMWARE) $(BUILD_DIR)
	$(YOSYS) -p "read_verilog ../build/exotiny_preproc.v;  read_verilog -sv ../src/tt_um_meiniKi_tt06_fazyrv_exotiny.sv; \
				read_verilog -sv ice40/tt06_fazyrv_exotiny_valid.sv; \
				synth_ice40 -top tt06_fazyrv_exotiny_valid; write_json $(ICO_SYNTH_FILE)"
	$(NEXTPNR_ICE40) --hx8k --package ct256 --pcf $(ICO_PCF) --json $(ICO_SYNTH_FILE) --freq 20 --asc $(ICO_ASC_FILE)
	$(ICEPACK) $(ICO_ASC_FILE) $(ICO_BIN_FILE)

$(FIRMWARE):
	make -C ../FazyRV-ExoTiny/sim/ firmware/rom.hex

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

clean:
	$(MAKE) -C firmware clean
	rm -rf $(BUILD_DIR)
