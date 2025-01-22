; setam originea pe 0x7c00, conventia pentru incarcarea bootloader-ului (adresa setata ca conventie)
; setam originea pe 0 daca ne setam singuri segmentele de date
ORG 0

BITS 16 ; setam modul de lucru pe 16 biti (real-mode)

; daca avem originea pe 0, trebuie sa sarim un "far jump" - segment:offset (start devine offset local in CS)
jmp 0x7c0:start

; pornim start label
start:
    ; setam segmentele de date - in caz ca BIOS-ul nu le seteaza corect
    cli ; dezactivam intreruperile
    mov ax, 0x7c0 ; nu avem voie sa setam direct valorile in registrii de segment, asa ca folosim ax ca al treilea pahar
    mov ds, ax
    mov es,ax

    ; setam stiva
    mov ax, 0x00
    mov ss, ax ; setam limita stivei pe 0 (stiva creste de jos in sus)
    mov sp, 0x7c00 ; stack pointer o sa fie la baza stivei

    sti ; activam intreruperile

    ; afisam Hello World!
    mov si, message ; mutam mesajul in registrul sursa (si - source register)
    call print ; apelam functia print
    jmp $ ; sarim la inceputul programului si reluam (loop infinit)

print:
.loop:
    lodsb ; preia fiecare caracter din `source register` si ii da output in AL
    cmp al, 0 ; daca AL este egal cu 0, am ajuns la capatul string-ului
    je .done ; daca compare-ul a fost TRUE, sarim la label-ul `.done`
    call print_char ; daca nu, mai avem caractere de afisat si apelam rutina `print_char`
    jmp .loop ; 
.done:
    ret ; iesim din rutina dupa ce am afisat tot string-ul

; subrutina care afiseaza un caracter
print_char:
    ; afisam un caracter pe ecran - http://www.ctyme.com/intr/rb-0106.htm
    ; registrul AL va fi setat de lodsb
    mov ah, 0eh
    mov bx, 0
    int 0x10
    ret

message: db 'Hello World!', 0 ; declaram variabila `message` cu valoarea `Hello World!`

; times afiseaza de un numar de ori o valoare - vom umple pana la 512 bytes cu valoarea 0
times 510-($ - $$) db 0
dw 0xAA55 ; semnatura de bootloader (vezi mai jos):
; push bp
; stosb