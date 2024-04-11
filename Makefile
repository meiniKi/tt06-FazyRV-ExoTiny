
preproc:
	mkdir -p build
	yosys -s synth/tt.ys

sim: preproc
	make -C sim test_vcd

sim.cocotb.default: preproc
	make -C sim firmware
	make -C test

sim.cocotb.gl:
	make -C sim firmware
	make -C test GATES=yes

clean:
	make -C sim clean