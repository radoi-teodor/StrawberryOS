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
# Burn ISO pe USB
Odata ce avem ISO-ul, putem sa il copiem pe disk folosind utilitarul `dd`:
```
sudo dd if=./boot.bin of=/dev/sdb
```
Presupunem ca USB-ul este incarcat in device pe `/dev/sdb`.