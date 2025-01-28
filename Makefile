FILES = ./build/kernel.asm.o

# implicit, Makefile vor executa primul label care apare in fisier
all: ./bin/boot.bin ./bin/kernel.bin # label-ul `all` - va avea ca dependente binarul bootloader si binarul kernel
	# stergem mereu OS.bin fiindca dd ii va face append, nu overwrite
	rm -rf ./bin/os.bin

	# scriem bootloader-ul in imaginea de OS
	dd if=./bin/boot.bin >> ./bin/os.bin
	dd if=./bin/kernel.bin >> ./bin/os.bin

	# umplem restul sectorului de kernel cu 0 (umplem inca 100 de sectoare de 512 bytes)
	dd if=/dev/zero bs=512 count=100 >> ./bin/os.bin

./bin/kernel.bin: $(FILES) # kernelul depinde de toate fisierele declarate in FILES
	# va combina toate fisierele intr-un singur fisier obiect kernelfull.o
	i686-elf-ld -g -relocatable $(FILES) -o ./build/kernelfull.o

	# va folosi fisierul linker.ld impreuna cu kernelfull.o (fisierul obiect) pentru a crea fisierul binar kernel.bin
	# -T - fisierul linker
	# -ffreestanding - nu e un mediu standard (nu avem OS sau librarii pe care sa le folosim ca dependenta)
	# -O0 - fara optimizari
	# -nostdlib - fara librarii STD
	i686-elf-gcc -T ./src/linker.ld -o ./bin/kernel.bin -ffreestanding -O0 -nostdlib ./build/kernelfull.o

# compilam bootloader-ul
./bin/boot.bin: ./src/boot/boot-protected.asm # punem dependenta pe codul sursa al bootloader-ului
	nasm -f bin ./src/boot/boot-protected.asm -o ./bin/boot.bin

# compilam kernelul
./build/kernel.asm.o: ./src/kernel.asm # punem dependenta pe codul sursa al kernel-ului
	nasm -f elf -g ./src/kernel.asm -o ./build/kernel.asm.o

# label de cleanup
clean:
	# stergem imaginile
	rm -rf ./bin/boot.bin

# make real-mode (bootloader limitat)
real: # label-ul `all`
	# compilam bootloader-ul
	nasm -f bin ./boot-real.asm -o ./boot.bin

	# scriem un fisier pe disk in al doilea sector (primul sector - bootloader-ul are 512 bytes)
	dd if=./message.txt >> ./boot.bin

	# scriem 512 bytes pe disk pentru a completa al doilea sector cu bytes (un sector nu poate avea mai putin de 512 bytes, daca vrem sa il citim/scriem)
	dd if=/dev/zero bs=512 count=1 >> ./boot.bin