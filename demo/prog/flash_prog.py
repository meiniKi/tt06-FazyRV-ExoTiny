#
# Adapted from 
# MichaelBell/tinyQV/blob/main/pico_ice/micropython/run_tinyqv.py
#
#

import time
from machine import SoftSPI, Pin

# For TT PCB (not tested yet on the actual TT PCB)
PIN_MISO        = "GP0"
PIN_SCK         = "GP2"
PIN_MOSI        = "GP3"
PIN_CS_FLASH    = "GP1"
PIN_CS_RAM_A    = "GP4"
PIN_CS_RAM_B    = "GP6"

#
#PIN_MISO = "GP4"
#PIN_SCK = "GP6"
#PIN_MOSI = "GP2"
#PIN_CS_FLASH = "GP1"
#PIN_CS_RAM_A = "GP5"
#PIN_CS_RAM_B = "GP7"

def init():
    for i in range(30):
        Pin(i, Pin.IN, pull=None)


def qe(do_write=False, enable=False):
    init()
    CMD_READ_SR1 = 0x05
    CMD_READ_SR2 = 0x35
    CMD_WEN = 0x06
    CMD_WRITE_NV_SR = 0x01

    spi = SoftSPI(baudrate=1_000_000, sck=Pin(PIN_SCK), mosi=Pin(PIN_MOSI), miso=Pin(PIN_MISO))

    flash_sel = Pin(PIN_CS_FLASH, Pin.OUT)
    ram_a_sel = Pin(PIN_CS_RAM_A, Pin.OUT)
    ram_b_sel = Pin(PIN_CS_RAM_B, Pin.OUT)

    flash_sel.on()
    ram_a_sel.on()
    ram_b_sel.on()

    def flash_cmd(data, dummy_len=0, read_len=0):
        dummy_buf = bytearray(dummy_len)
        read_buf = bytearray(read_len)
        
        flash_sel.off()
        spi.write(bytearray(data))
        if dummy_len > 0:
            spi.readinto(dummy_buf)
        if read_len > 0:
            spi.readinto(read_buf)
        flash_sel.on()
        
        return read_buf
    
    def flash_cmd2(data, data2):
        flash_sel.off()
        spi.write(bytearray(data))
        spi.write(data2)
        flash_sel.on()
    
    def print_bytes(data, prefix=""):
        print(prefix, end="")
        for b in data: print("%02x " % (b,), end="")
        print()
    
    if do_write:
        print("Reading...")
        sr1 = flash_cmd([CMD_READ_SR1], 0, 1)
        sr2 = flash_cmd([CMD_READ_SR2], 0, 1)

        print_bytes(sr1, "SR1: ")
        print_bytes(sr2, "SR2: ")

        # Set / Clear QE
        print("Enabling" if enable else "Disabling")
        if enable:
            sr2[0] |= (1 << 1)
        else:
            sr2[0] &= ~(1 << 1)
            
        # Ensure that we don't write any OTP
        sr2[0] &= ~((1 << 5) | (1 << 4) | (1 << 3))

        print("Attempting to write: ")
        sr_write = sr1 + sr2
        print_bytes(sr1, "SR1: ")
        print_bytes(sr2, "SR2: ")
        print_bytes(sr_write, "to write: ")
        s = input("Continue? [y/N]")

        if s == "y":
            print("Writing...")
            flash_cmd([CMD_WEN])
            flash_cmd2(CMD_WRITE_NV_SR, sr_write)
    
    print("Reading ...")
    sr1 = flash_cmd([CMD_READ_SR1], 0, 1)
    sr2 = flash_cmd([CMD_READ_SR2], 0, 1)
    print_bytes(sr1, "SR1: ")
    print_bytes(sr2, "SR2: ")


def program(filename):
    for i in range(30):
        Pin(i, Pin.IN, pull=None)

    spi = SoftSPI(baudrate=1_000_000, sck=Pin(PIN_SCK), mosi=Pin(PIN_MOSI), miso=Pin(PIN_MISO))

    flash_sel = Pin(PIN_CS_FLASH, Pin.OUT)
    ram_a_sel = Pin(PIN_CS_RAM_A, Pin.OUT)
    ram_b_sel = Pin(PIN_CS_RAM_B, Pin.OUT)

    flash_sel.on()
    ram_a_sel.on()
    ram_b_sel.on()

    def flash_cmd(data, dummy_len=0, read_len=0):
        dummy_buf = bytearray(dummy_len)
        read_buf = bytearray(read_len)
        
        flash_sel.off()
        spi.write(bytearray(data))
        if dummy_len > 0:
            spi.readinto(dummy_buf)
        if read_len > 0:
            spi.readinto(read_buf)
        flash_sel.on()
        
        return read_buf

    def flash_cmd2(data, data2):
        flash_sel.off()
        spi.write(bytearray(data))
        spi.write(data2)
        flash_sel.on()

    def print_bytes(data):
        for b in data: print("%02x " % (b,), end="")
        print()

    CMD_WRITE = 0x02
    CMD_READ = 0x03
    CMD_READ_SR1 = 0x05
    CMD_WEN = 0x06
    CMD_SECTOR_ERASE = 0x20
    CMD_ID = 0x90
    CMD_LEAVE_CM = 0xFF

    flash_cmd([CMD_LEAVE_CM])
    id = flash_cmd([CMD_ID], 2, 3)
    print_bytes(id)

    with open(filename, "rb") as f:
    #if False:
        buf = bytearray(4096)
        sector = 0
        while True:
            num_bytes = f.readinto(buf)
            #print_bytes(buf[:512])
            if num_bytes == 0:
                break
            
            flash_cmd([CMD_WEN])
            flash_cmd([CMD_SECTOR_ERASE, sector >> 4, (sector & 0xF) << 4, 0])

            while flash_cmd([CMD_READ_SR1], 0, 1)[0] & 1:
                print("*", end="")
                time.sleep(0.01)
            print(".", end="")

            for i in range(0, num_bytes, 256):
                flash_cmd([CMD_WEN])
                flash_cmd2([CMD_WRITE, sector >> 4, ((sector & 0xF) << 4) + (i >> 8), 0], buf[i:min(i+256, num_bytes)])

                while flash_cmd([CMD_READ_SR1], 0, 1)[0] & 1:
                    print("-", end="")
                    time.sleep(0.01)
            print(".")
            sector += 1
            
        print("Program done")

    with open(filename, "rb") as f:
        data = bytearray(256)
        i = 0
        while True:
            num_bytes = f.readinto(data)
            if num_bytes == 0:
                break
            
            data_from_flash = flash_cmd([CMD_READ, i >> 8, i & 0xFF, 0], 0, num_bytes)
            for j in range(num_bytes):
                if data[j] != data_from_flash[j]:
                    raise Exception(f"Error at {i:02x}:{j:02x}: {data[j]} != {data_from_flash[j]}")
            i += 1

    print("Verify done")
    data_from_flash = flash_cmd([CMD_READ, 0, 0, 0], 0, 16)
    print_bytes(data_from_flash)


#qe(do_write=False, enable=True)
program("firmware.bin")
print("Done.")