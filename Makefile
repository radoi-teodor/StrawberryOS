# implicit, Makefile vor executa primul label care apare in fisier
all: # label-ul `all`
	# compilam bootloader-ul
	nasm -f bin ./boot-protected.asm -o ./boot.bin

	# scriem un fisier pe disk in al doilea sector (primul sector - bootloader-ul are 512 bytes)
	dd if=./message.txt >> ./boot.bin

	# scriem 512 bytes pe disk pentru a completa al doilea sector cu bytes (un sector nu poate avea mai putin de 512 bytes, daca vrem sa il citim/scriem)
	dd if=/dev/zero bs=512 count=1 >> ./boot.bin