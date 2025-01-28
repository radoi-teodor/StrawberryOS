[BITS 32] ; setam subrutina sa ruleze pe 32 de biti
global _start ; va exporta symbolul _start

; definim segmentul code - 0x08 de la inceputul GDT
CODE_SEG equ 0x08
; definim segmentul data - 0x10 de la inceputul GDT
DATA_SEG equ 0x10

; definim label-ulde start cu numele _start
_start:
	; vom seta segmentele de memorie
	mov ax, DATA_SEG
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	mov ebp, 0x00200000 ; 2097152 bytes - 2 megabytes pentru stiva
	mov esp, ebp

	; activam A20 line
	in al, 0x92
	or al, 2
	out 0x92, al

    ; loop infinit
    jmp $

