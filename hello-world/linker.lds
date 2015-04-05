OUTPUT_ARCH(mips)
ENTRY(_start)
SECTIONS
{
  /* Read-only sections, merged into text segment: */
  . = 0x94020000;

  .text    : {
    *(.text.entry)
    *(.text)
    *(.rodata)
  } =0

  .data : { *(.data) }

  .reginfo : { *(.reginfo) }

  .bss     : { *(.bss) }
}
