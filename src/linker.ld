ENTRY(_start) /* entry point al programului nostru - vezi boot-protected.asm */
OUTPUT_FORMAT(binary) /* nu incarcam headere - fisier binar in plain */
SECTIONS
{
    /* ORIGINEA definita in linker - sectiunile vor incepe de la 1 MB */
    . = 1m; /* kernel-ul o sa fie incarcat intr-un MB de memorie */
    /* 1024 * 1024 = bytes intr-un MB => 0x100000 adresa de memorie la care vor incepe sectiunile */

    /* definim sectiunile */

    .text :
    {
        *(.text)
    }

    /* Read-Only data */
    .rodata :
    {
        *(.rodata)
    }

    .data :
    {
        *(.data)
    }

    .bss :
    {
        *(COMMON)
        *(.bss)
    }
}