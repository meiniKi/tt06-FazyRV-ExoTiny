
This folder contains a simple hello-world demo for the TT06 bring-up.


## Build the Demo Firmware

Go to the firmware directory and execute the make target. It automatically builds the firmware and extracts a `.bin` and ASCII-readable `.hex` representation. Make sure to have RISC-V GCC in your path.

```shell
cd demo/firmware/
make
cd ..
```

## Flash the Firmware to the QPSI PMOD

You need to copy the flash script to the Raspberry Pi Pico. You can use `rshell`. You may need to modify the device `/dev/ttyACMx`.

```shell
cd demo
rshell -p /dev/ttyACM0 --buffer-size 512 cp prog/flash_prog.py /pyboard/flash_prog.py
```

Afterward, you can copy your firmware file to the Pico and use that script to flash it to the QSPI PMOD. Again, you might need to select a different device on your computer.

```shell
rshell -p /dev/ttyACM0 --buffer-size 512 cp firmware/build/firmware.bin /pyboard/firmware.bin && rshell -p /dev/ttyACM0 --buffer-size 512 repl "~ exec(open('/flash_prog.py').read()) ~"
```

You should get an output similar to

```
Program done
Verify done
93 00 00 00 13 01 00 00 93 01 00 00 13 02 00 00 
Done.
```

## Success!

Select the TT06-FazyRV-Exotiny design and enjoy the beautiful LED show (or your custom firmware running).

<p align="center">
  <img src="demo.gif" />
</p>
</td>
<td>


## (optional) Emulate the ASIC design in an FPGA

If you don't have the TT06 board yet (like me), you can emulate the design using an ULX3S FPGA board (or a different one with some slight modifications). Go back to the root of this repository (i.e., `cd <repo>`). If you haven't installed `fusesoc`, now is the time. Once installed, add the `tt06emu` core.

```shell
fusesoc library add tt06emu.core .
```

Now, you can implement the design and flash it to the board.

```shell
make preproc
fusesoc run --target=ulx3s tt06emu
openFPGALoader -d /dev/ttyUSB0 -b ulx3s build/tt06emu_0.0.1/ulx3s-trellis/tt06emu_0.0.1.bit
```
