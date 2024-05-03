# RorthOS
This is the base code for the OS i've written in 2020


* Compile the code (Using nasm)
  - nasm -f bin boot.asm -o boot.bin

* Emulator (QEMU)
  - qemu-system-x86_64 -hda boot.bin
