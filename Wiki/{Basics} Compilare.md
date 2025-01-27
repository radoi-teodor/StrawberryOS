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
# Compilare GCC - Ubuntu
Nu putem folosi GCC out of the box, fiindca este facut sa ruleze pe Linux, asa ca va trebui sa ne compilam propriul compilator GCC care sa ne permita compilarea de programe pe propriul sistem de operare: https://wiki.osdev.org/GCC_Cross-Compiler.
Vom instala dependentele:
```
apt install build-essential -y
apt install bison -y
apt install flex -y
apt install libgmp3-dev -y
apt install libmpc-dev -y
apt install libmpfr-dev -y
apt install texinfo -y
apt install texinfo -y
apt install libisl-dev -y
```

Vom descarca BINUtils (de pe serverul FTP https://ftp.gnu.org/gnu/binutils/), ultima versiune, arhiva `.tar.xz`.
Vom descarca codul sursa GCC, versiunea 10.2 (de pe serverul FTP https://ftp.lip6.fr/pub/gcc/releases/gcc-10.2.0/), arhiva `.tar.gz`.

Dupa, vom urma pasii de compilare de pe OSDev: https://wiki.osdev.org/GCC_Cross-Compiler#The_Build (pentru BINUtils si GCC).

Dupa compilare si instalare, vom putea verifica compilatorul folosind:
```
$HOME/opt/cross/bin/$TARGET-gcc --version
```
Comanda de mai sus functioneaza doar daca avem variabilele de sistem setate corect (precum ne specifica pe OSDev: https://wiki.osdev.org/GCC_Cross-Compiler#The_Build):
```
export PREFIX="$HOME/opt/cross"
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"
```