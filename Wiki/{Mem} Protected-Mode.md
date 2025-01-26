**Protected-Mode** este un mod de compatibilitate al CPU-ului care ofera acces la arhitectura x86.
Avantaje:
- ne ofera acces la 4GB RAM
- ne ofera protectie a memoriei si protectie hardware

**Protected-Mode** ne ofera acces la protection rings, un model de protectie al memoriei:

![](Wiki/imgs/protection-rings.png)

**Ring 0** este cel mai privilegiat inel de protectie si permite accesul total pe device-ul respectiv. **Kernel-ul** opereaza in **ring 0**.
**Ring 3** este inelul de protectie care permite rularea programelor obisnuite.

Pentru a realiza comunicarea dintre *un program care ruleaza pe ring 3* si *kernel*, se realizeaza **o intrerupere** din program. Asta ii va spune CPU-ului sa se mute de pe memoria de *ring 3* in memoria de *ring 0*.

Exista mai multe scheme de memorie:
- **selector memory scheme** - folosim registrii de memorie pentru a stoca ce *range-uri de memorie* sunt alocate *fiecarui ring de protectie*
- **schema de paginare** - creem un nou layer de abstractizare numit **memorie virtuala** pe care o mapam pe **memoria fizica**

# Paginare de Memorie
Schema de paginare de memorie este conceputa dintr-un director de memorii numit **page directory** care retine offset-urile fiecarei pagini in memorie. Astfel, fiecare pagina va folosi acelasi range prestabilit. Asta permite fiecarui proces sa creada ca ruleaza unic in memoria virtuala prestabilita de pagina alocata.

![](Wiki/imgs/page-scheme.png)

# Pregatire & Switch in Protected-Mode
Odata ce vom schimba in **Protected-mode**, vom avea acces la toate beneficiile **protected-mode**, insa nu vom mai putea folosi *intreruperile de BIOS*.
Intai va trebui sa definim niste [tabele global descriptor](https://wiki.osdev.org/GDT_Tutorial#What_to_Put_In_a_GDT). Aceste tabele definesc sectiuni de memorie cu anumite protectii (precum protectie de kernel - ring 0).

Fiecare tabel trebuie sa fie la un anumit offset relativ la inceputul Global Table Descriptor, de aceea, tabelele trebuie scrise intr-o ordine specifica.

Structura unui tabel global descriptor este (marime - 2x double dword):

| 63   56               | 55   52              | 51   48                | 47   40                    | 39   32               | 31   16              | 15   0                |
| --------------------- | -------------------- | ---------------------- | -------------------------- | --------------------- | -------------------- | --------------------- |
| **Base**  <br>31   24 | **Flags**  <br>3   0 | **Limit**  <br>19   16 | **Access Byte**  <br>7   0 | **Base**  <br>23   16 | **Base**  <br>15   0 | **Limit**  <br>15   0 |

Fiindca lucram in little endian, va trebui sa creem structurile punand valori de la dreapta la stanga.

**Access Byte** este o proprietate masca de biti care arata similar cu (vezi fiecare parametru documentat pe: https://wiki.osdev.org/Global_Descriptor_Table#Segment_Descriptor):

| 7     | 6       | 5   | 4     | 3     | 2      | 1      | 0     |
| ----- | ------- | --- | ----- | ----- | ------ | ------ | ----- |
| **P** | **DPL** |     | **S** | **E** | **DC** | **RW** | **A** |

**Flag-urile** reprezinta o masca de biti care seteaza flag-urile setate pe segmentul respectiv de memorie si arata simular cu (vezi fiecare parametru documentat pe: https://wiki.osdev.org/Global_Descriptor_Table#Segment_Descriptor):

|3|2|1|0|
|---|---|---|---|
|**G**|**DB**|**L**|Reserved|


Va trebui sa implementam urmatoarele *tabele global descriptor*:
- Null Descriptor

```
gdt_null:
	dd 0x0
	dd 0x0
```


- Kernel Mode Code Segment:

```
gdt_code:
	dw 0xffff ; segment limit - sfarsitul segmentului kernel code
	dw 0 ; segment base - inceputul segmentului kernel code
	db 0 ; segment base - inceputul segmentului kernel code
	db 0x9a ; masca de biti pentru acces in segmentul de cod din kernel
	db 11001111b ; flag-urile 
	db 0 ; segment base - inceputul segmentului kernel code
```

- Kernel Mode Data Segment:

```
gdt_data:
	dw 0xffff ; segment limit - sfarsitul segmentului kernel code
	dw 0 ; segment base - inceputul segmentului kernel code
	db 0 ; segment base - inceputul segmentului kernel code
	db 0x92 ; masca de biti pentru acces in segmentul de cod din kernel
	db 11001111b ; flag-urile 
	db 0 ; segment base - inceputul segmentului kernel code
```


Toate aceste sectiuni se vor insera intre doua label-uri (`gdt_start` si `gdt_end`):
```
gdt_start:
; sectiuni GDT setate
gdt_end:
```

Asta ne va permite sa setam foarte usor descriptorul mare pentru toate tabelele create (numit [GDT Descriptor](https://wiki.osdev.org/Global_Descriptor_Table)):
```
gdt_descriptor:
	dw gdt_end - gdt_start - 1
	dd gdt_start
```
Avand structura:

|79 (64-bit mode)  <br>48 (32-bit mode)   16|15   0|
|---|---|
|**Offset**  <br>63 (64-bit mode)  <br>31 (32-bit mode)   0|**Size**  <br>  <br>15   0|


Unde:
- `Offset` - offset-ul absolut al tabelului GDT
- `Size` - marimea tabelului GDT
## Switch in Protected-Mode
Odata ce am setat totul in legatura cu GDT, vom putea face switch-ul:
```
; calculam adresa relativa a segmentului kernel code
CODE_SEG equ gdt_code - gdt_start
; calculam adresa relativa a segmentului kernel data
DATA_SEG equ gdt_data - gdt_start

; definim un label pentru switch-ul pe protected-mode
.load_protected:
	cli ; dezactivam intreruperile
	; lgdt - load global descriptor table
	lgdt[gdt_descriptor]

	mov eax, cr0 ; mutam valoarea actuala a registrului cr0
	or eax, 0x1 ; setam registrul eax pe 1 (activam protected-mode)
	mov cr0, eax ; setam cr0 pe 1
	
	jmp CODE_SEG:load32 ; sarim la subrutina care va rula in protected mode

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
```


Observam ca in `.load_protected` modificam valoarea registrului `CR0` pe 1. Acest registru este cel care seteaza protected-mode in CPU-uri. Setand-ul pe 1, modificam environment-ul in protected.