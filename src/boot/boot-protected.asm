; setam originea pe 0x7c00, conventia pentru incarcarea bootloader-ului (adresa setata ca conventie)
; setam originea pe 0 daca ne setam singuri segmentele de date
ORG 0x7c00

BITS 16 ; setam modul de lucru pe 16 biti (real-mode)

; calculam adresa relativa a segmentului kernel code
CODE_SEG equ gdt_code - gdt_start
; calculam adresa relativa a segmentului kernel data
DATA_SEG equ gdt_data - gdt_start

; creem un initial _start label pentru a pune dupa el `BIOS parameter block`
_start:
    jmp short start
    nop

; umplem `BIOS parameter block` cu 0 pentru a crea compatibilitatea cu toate BIOS-urile
times 33 dw 0


; pornim start label - folosim start label pentru a sari `in code segment`
start:
    ; daca avem originea pe 0, trebuie sa sarim un "far jump" - segment:offset (start devine offset local in CS)
    jmp 0:step2


step2:
    ; setam segmentele de date - in caz ca BIOS-ul nu le seteaza corect
    cli ; dezactivam intreruperile
    mov ax, 0 ; nu avem voie sa setam direct valorile in registrii de segment, asa ca folosim ax ca al treilea pahar
    mov ds, ax
    mov es,ax

    ; setam stiva
    mov ss, ax ; setam limita stivei pe 0 (stiva creste de jos in sus)
    mov sp, 0x7c00 ; stack pointer o sa fie la baza stivei

    sti ; activam intreruperile

    ; sarim peste asta pentru a intra in .load_protected label
    ;jmp $ ; sarim la inceputul programului si reluam (loop infinit)


; definim un label pentru switch-ul pe protected-mode
.load_protected:
	cli ; dezactivam intreruperile
	; lgdt - load global descriptor table
	lgdt[gdt_descriptor]

	mov eax, cr0 ; mutam valoarea actuala a registrului cr0
	or eax, 0x1 ; setam registrul eax pe 1 (activam protected-mode)
	mov cr0, eax ; setam cr0 pe 1
	
	jmp CODE_SEG:load32 ; sarim la subrutina care va rula in protected mode

; setam GDT
gdt_start:

gdt_null:
	dd 0x0
	dd 0x0

gdt_code:
	dw 0xffff ; segment limit - sfarsitul segmentului kernel code
	dw 0 ; segment base - inceputul segmentului kernel code
	db 0 ; segment base - inceputul segmentului kernel code
	db 0x9a ; masca de biti pentru acces in segmentul de cod din kernel
	db 11001111b ; flag-urile 
	db 0 ; segment base - inceputul segmentului kernel code

gdt_data:
	dw 0xffff ; segment limit - sfarsitul segmentului kernel code
	dw 0 ; segment base - inceputul segmentului kernel code
	db 0 ; segment base - inceputul segmentului kernel code
	db 0x92 ; masca de biti pentru acces in segmentul de cod din kernel
	db 11001111b ; flag-urile 
	db 0 ; segment base - inceputul segmentului kernel code

gdt_end:

gdt_descriptor:
	dw gdt_end - gdt_start - 1
	dd gdt_start

[BITS 32] ; setam subrutina sa ruleze pe 32 de biti
load32:
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

; times afiseaza de un numar de ori o valoare - vom umple pana la 512 bytes cu valoarea 0
times 510-($ - $$) db 0
dw 0xAA55 ; semnatura de bootloader (vezi mai jos):
; push bp
; stosb