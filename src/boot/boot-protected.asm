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
	
	; jmp $ ; jump infinit
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

[BITS 32]
load32:
	mov eax, 1 ; incepem sa incarcam de la sectorul 1
	mov ecx, 100 ; numarul total de sectoare pe care citim
	mov edi, 0x0100000 ; mutam un MB
	call ata_lba_read
	; sarim in kernel
	jmp CODE_SEG:0x0100000

ata_lba_read:
	mov ebx, eax ; facem backup primului sector pe care vrem sa il citim

	; trimitem primii 8 biti catre controller-ul de hard disk
	shr eax, 24 ; muta bitii din EAX 24 de biti la stanga (bitshift)
	or eax, 0xE0 ; selectam drive-ul master
	mov dx, 0x1F6
	out dx, al
	; am trimis primii 8 biti catre controller-ul de hard disk

	; trimitem sectoarele totale de citit
	mov eax, ecx
	mov dx, 0x1F2
	out dx, al
	; am trimis sectoarele totale de citit

	; trimitem mai multi biti din LBA
	mov eax, ebx
	mov dx, 0x1F2
	out dx, al
	; am trimis mai multi biti din LBA


	mov dx, 0x1F2
	mov eax, ebx ; facem restore LBA
	shr eax, 8
	out dx, al

	mov dx, 0x1F2
	mov eax, ebx ; facem restore LBA
	shr eax, 16
	out dx, al

	mov dx, 0x1F2
	mov al, 0x20
	out dx, al

; citim toate sectoarele in memorie
.next_sector:
	push ecx

; verificam de ce avem nevoie sa citim
.try_again:
	mov dx, 0x1F7
	in al, dx
	test al, 0
	jz .try_again

	; citim cate 256 de bytes
	mov ecx, 256
	mov dx, 0x1F0
	rep insw
	pop ecx

	; vom trece la urmatorul sector
	loop .next_sector

	; am terminat de citit
	ret

; times afiseaza de un numar de ori o valoare - vom umple pana la 512 bytes cu valoarea 0
times 510-($ - $$) db 0
dw 0xAA55 ; semnatura de bootloader (vezi mai jos):
; push bp
; stosb