**Real-Mode** este un mod de compatibilitate a CPU-urilor (toate CPU-urile moderne au) care simuleaza modul de comportare original x86. Practic, CPU-ul se va comporta ca CPU-urile initiale din 1970.

Limitari:
- avem acces doar la 1MB RAM
- nu avem nicio masura de protectie (orice eroare nenoroceste sistemul)
- doar 16 biti accesibili de o data (sistemul este x16)

# BIOS Parameter Block
**BIOS Parameter Block** este o structura care defineste layout-ul fizic al memoriei in calculator. Pentru ca ISO-ul nostru sa poata boota pe orice masina fizica, trebuie sa umplem BIOS Parameter Block cu 0. Structura completa are 33 bytes si pentru a o umple din bootloader, inainte sa intram in code segment, va trebui sa folosim:
```
times 33 dw 0
```
# Disk
**Disk-ul** nu are cu adevarat un concept de *fisier*. Disk-ul doar stocheaza informatie in sectoare de cate 512 bytes. Daca vrem sa citim un anumit sector, ni se vor returna 512 bytes. *Fisierele* sunt de fapt niste concepte de kernel.

Exista mai multe moduri de a scrie/citi un hard disk:
- `CHS (Cylinder Head Sector)` - pentru a citi/scrie un sector trebuie sa ii spunem disk-ul (head - un hard disk are mai multe disk-uri), sector-ul (trebuie sa stim cate sectoare sunt) si track-ul (cilindrul concentric de pe disk-ul tinta) - METODA VECHE
- `LBA (Logical Block Address)` - pentru a citi/scrie, specificam un numar care incepe de la 0 (este ca si cum am citi un fisier mare de date):

```
LBA0 - primul sector de pe disk
LBA1 - al doilea sector de pe disk
...........
```
Pentru a afla sectorul unei adrese `X` de pe memorie pe hard disk, vom calcula `X/512` (fiecare sector are 512 bytes). Pentru a calcula offset-ul, vom folosi `X%512`.

In 16 but real-mode, BIOS-ul implementeaza *interuperea 13H* pentru operatii pe disk. In modul 32 de biti, trebuie sa ne creem singuri driverul care face operatii pe disk.

## Real-mode Disk Read
Pentru a citi de pe disk folosind `CHS` in real-mode, vom folosi intreruperea 13 (vezi documentatia: http://www.ctyme.com/intr/rb-0607.htm).
Memoria citita se va incarca in registrul `ES`, la offset-ul `BX`, deci memoria absoulta va fi:
```
ES*16+BX
```
