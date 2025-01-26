Exemplu registru EAX:
```
----------------------
|         EAX        |
|    32    | 16 | 16 | 
|          | AH | AL |
----------------------
```

`$` - adresa curenta de executie
`$$` - adresa de inceput a sectiunii curente

`DB` - definim un byte (8 biti)
`DW` - definim un DWORD, 2 bytes pe sistemele x86 (16 biti)
`DD` - definim un DOUBLE DWORD (32 biti)

## Segmente de memorie
Segmentele de memorie sunt folosite pentru a accesa memoria RAM.
Registrii:
- `CS` - code segment
- `SS` - stack segment
- `DS` - data segment
- `ES` - extra segment

Pentru a calcula o adresa absoluta (sa numim `abs`) dintr-un segment (adresa absoluta a unui segment, o vom numi `seg`), folosind valoarea locala din segmentul respectiv (sa o numim `loc`), vom folosi formula:
```
abs = seg * 16 + loc
```
Asta fiindca operam pe 16 bytes, iar memoria abstracta este o matrice cu 16 coloane. Memoria CPU-ului fiind liniara, va trebui sa sarim 16 casute pentru fiecare valoare a adresei segmentului. Apoi vom adauga valoarea absoluta ca pe un offset.
Exemplu calculat:
```
code segment = 0x7c0
originea (inceputul memoriei) = 0
presupunem ca adresa primei instructiuni este 0
adresa_primei_instructiuni = 0x7c0 * 16 =  0x7c00
```
### Segmentul Stack (Mod de Functionare)
Presupunem
- `SS` (stack segment) = 0x00
- `SP` (stack pointer) = 0x7c00 (fara sa adaugam nimic in stiva, asta este si baza stivei)

Daca vom executa:
```
push 0xffff
```
1. Vom scadea din `SP` valoarea 2 (dimensiunea valorii bagate in stiva)
Stack pointer astfel va fi: `SP` = 0x7BFE

2. Se va seta in intervalul de memorie 0x7BFE-0x7c00 valoarea 0xffff.
## Jump
Avem doua tipuri de jump:
- far jump - sarim la cod assembly din alt modul
- short jump - sarim la cod assembly din acelasi modul

## Intreruperile
`Intreruperile` sunt exact ca subrutinele, insa nu trebuie sa stim adresa lor pentru a le apela. Putem folosi numarul unei intreruperi pentru a o apela.
Procesul unei intreruperi:
1. Procesul este intrerupt
2. State-ul vechi al procesului este salvat pe stiva
3. Intreruperea este executata

**Interrupt vector table** este tabelul care contine toate intreruperile oferite de sistem (256 de intreruperi). Tabelul incepe de la adresa 0 din memoria RAM si fiecare intrerupere contine doua proprietati:
- offset (2 bytes) - adresa relativa la segmentul de memorie
- segment (2 bytes) - adresa segmentului de memorie
Fiecare proprietate descrie unde se afla fiecare intrerupere, iar fiecare intrerupere contine 4 bytes.
Intreruperile se afla in ordine asa ca, la adresa absoluta din RAM:
- 0x00 - intreruperea 0
- 0x04 - intreruperea 1
- 0x08 - intreruperea 2
...........

Putem adauga propria noastra definitie pentru fiecare intrerupere:
```
; definim rutina care se va apela in intrerupere
handle_zero:
    ; vom afisa 'A' pe ecran
    mov ah, 0eh
    mov al, 'A'
    mov bx, 0x00
    int 0x10
    iret ; returnam dintr-o subrutina

; setam intreruperea 0
mov word[ss:0x00], handle_zero ; la adresa 0 din memoria RAM vom arunca in offset-ul intreruperii 0, adresa label-ului `handle_zero`
mov word[ss:0x02], 0x7c0 ; scriem segmentul de memorie unde se afla definitia intreruperii
```
