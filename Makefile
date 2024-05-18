exec = rorth.out
objects = $(sources:.c=.o)

$(exec): $(objects)
	nasm -f bin boot.asm -o boot.bin
	dd if=./message.txt >> boot.bin
	dd if=/dev/zero bs=512 count=1 >> ./boot.bin
	qemu-system-x86_64 -drive file=boot.bin,format=raw


c: # Clean
	-rm *.bin
