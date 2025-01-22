# General
Vom avea nevoie de:
- NASM
- QEMU

Codul va fi cat se poate de comentat pentru a putea servi ca referinta pentru orice dezvoltator de kernel.

# Assembly
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


# Compilare
Pentru a compila bootloader-ul vom folosi:
```
nasm -f bin boot.asm -o boot.bin
```

Asta va compila intr-un fisier binar simplu. Fisierele binare simple nu au headere, ci doar codul assembly, transpus in cod masina. Asta este formatul pe care stie sa il execute procesorul direct, fara sistem de operare.

---------------------------------

Dupa, vom avea un fisier `boot.bin` pe care il putem boota folosind QEMU (parametrul `hda` reprezinta hard disk-ul):
```
qemu-system-x86_64 -hda boot.bin
```

Daca vrem sa vedem codul assembly compilat, putem folosi:
```
ndisasm boot.bin
```
Asta ne va afisa codul masina si instructiunile assembly.

# Real-Mode
**Real-Mode** este un mod de compatibilitate a CPU-urilor (toate CPU-urile moderne au) care simuleaza modul de comportare original x86. Practic, CPU-ul se va comporta ca CPU-urile initiale din 1970.

Limitari:
- avem acces doar la 1MB RAM
- nu avem nicio masura de protectie (orice eroare nenoroceste sistemul)
- doar 16 biti accesibili de o data (sistemul este x16)

# Referinte
Documentatii Intreruperi de BIOS - http://www.ctyme.com/intr/int.htm
