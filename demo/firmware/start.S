

.section .text
.global _start
.global main

_start:
    addi x1, zero, 0
    addi x2, zero, 0
    addi x3, zero, 0
    addi x4, zero, 0
    addi x5, zero, 0
    addi x6, zero, 0
    addi x7, zero, 0
    addi x8, zero, 0
    addi x9, zero, 0
    addi x10, zero, 0
    addi x11, zero, 0
    addi x12, zero, 0
    addi x13, zero, 0
    addi x14, zero, 0
    addi x15, zero, 0
    addi x16, zero, 0
    addi x17, zero, 0
    addi x18, zero, 0
    addi x19, zero, 0
    addi x20, zero, 0
    addi x21, zero, 0
    addi x22, zero, 0
    addi x23, zero, 0
    addi x24, zero, 0
    addi x25, zero, 0
    addi x26, zero, 0
    addi x27, zero, 0
    addi x28, zero, 0
    addi x29, zero, 0
    addi x30, zero, 0
    addi x31, zero, 0


	// Copy .data section from ROM to RAM
	la      t0, __data_size
	la      t1, __data_rom_start
	la      t2, __data_ram_start
	copy_rom_loop:
	beqz    t0, copy_rom_loop_end
	lw      t3, 0(t1)
	sw      t3, 0(t2)
	addi    t1, t1, 4
	addi    t2, t2, 4
	addi    t0, t0, -4;
	j       copy_rom_loop
    copy_rom_loop_end:

	// clear the bss segment
	la      t0, __bss_start
	la      t1, __bss_end
    clear_bss_loop:
    bge     t0, t1, clear_bss_end
    sw      zero, 0(t0)
    addi    t0, t0, 4
    j       clear_bss_loop
    clear_bss_end:

	li		tp, 0
    li		sp, 0x10001000
	li		a0, 0		// a0 = argc
	li		a1, 0		// a1 = argv
	li		a2, 0		// a2 = envp = NULL

    j main

hlt:
    j hlt