
PYTHON := python3
IVERILOG := iverilog$(ICARUS_SUFFIX)
VVP := vvp$(ICARUS_SUFFIX)

FIRMWARE 	= ../FazyRV-ExoTiny/sim/firmware/rom.hex

SRC_SOC 	= $(wildcard ../build/*.v)
SRC_TT 		= $(wildcard ../src/*.v ../src/*.sv)
SRC_MODELS 	= ../FazyRV-ExoTiny/tb/spiflash.v ../FazyRV-ExoTiny/tb/qspi_psram.sv
SRC_SIM 	= $(wildcard ../tb/*.v ../tb/*.sv)

test: testbench.vvp $(FIRMWARE)
	$(VVP) -N $< +firmware=$(FIRMWARE)

test_vcd: testbench.vvp $(FIRMWARE)
	$(VVP) -N $< +vcd +noerror +firmware=$(FIRMWARE)

testbench.vvp: $(SRC_SOC) $(SRC_TT) $(SRC_MODELS) $(SRC_SIM) 
	$(IVERILOG) -g2005-sv -DSIM -DDEBUG -o $@ $^
	chmod -x $@

firmware: $(FIRMWARE)
	@echo "done"

$(FIRMWARE):
	make -C ../FazyRV-ExoTiny/sim/ firmware/rom.hex

clean:
	make -C ../FazyRV-ExoTiny/sim/ clean

.PHONY: test test_vcd
