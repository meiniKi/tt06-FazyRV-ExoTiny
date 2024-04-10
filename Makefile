

preproc:
	mkdir -p build
	yosys -s synth/tt.ys

sim: preproc
	make -C sim test_vcd


clean:
	make -C sim clean