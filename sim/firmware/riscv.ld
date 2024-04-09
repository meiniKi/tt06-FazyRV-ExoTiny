

OUTPUT_FORMAT("elf32-littleriscv", "elf32-littleriscv",
	      "elf32-littleriscv")
OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY {
	rom (rx)    : ORIGIN = 0x00000000, LENGTH = 0x00018000
	ram (xrw)   : ORIGIN = 0x10000000, LENGTH = 0x00020000
}

SECTIONS
{
	.text : 
	{
		. = ALIGN(4);
		*(.text)
		*(.text.*)
		*(.gnu.linkonce.t.*)
		. = ALIGN(4);
		*(.rdata)
		*(.rodata)
		*(.rodata.*)
		*(.gnu.linkonce.r.*)
	} > rom

	.data : 
	{
		. = ALIGN(4);
		PROVIDE(__data_ram_start = .);
		*(.data)
		*(.data.*)
		*(.gnu.linkonce.d.*)
		*(.sdata)
		*(.sdata.*)
		*(.srodata.*)
		*(.gnu.linkonce.s.*)
		. = ALIGN(4);
	} > ram AT > rom

	PROVIDE(__data_rom_start = LOADADDR(.data));
	PROVIDE(__data_size = SIZEOF(.data));

	. = ALIGN(4);
	PROVIDE (__bss_start = .);

	.bss : 
	{
		*(.sbss)
		*(.sbss.*)
		*(.gnu.linkonce.sb.*)

		*(.bss)
		*(.bss.*)
		*(.gnu.linkonce.b.*)
		*(COMMON) 
	} > ram

	. = ALIGN(4);
	PROVIDE (__bss_end = .);
	PROVIDE (__bss_size = SIZEOF(.sbss) + SIZEOF(.bss));
}