all: btl.bin ke.o main.o kernel.tmp kernel.bin kernel_boot otp.txt

#BOOTLOADER IN BIN
btl.bin : mbr.asm
	nasm -o btl.bin mbr.asm 

#KERNEL ENTRY IN .O
ke.o : kernel_entry.asm
	nasm -f win32 -o ke.o kernel_entry.asm

#KERNEL IN .O
main.o : main.cpp
	g++ -Wall -m32 -g -std=c++14 -std=c++1y  -ffreestanding -nostartfiles -c main.cpp -o main.o
   
#LINK TRA KERNEL ENTRY E KERNEL    
kernel.tmp : ke.o main.o 
	ld -m i386pe -o kernel.tmp -Ttext 0x1000 ke.o main.o -LD:\mingw\mingw\lib\gcc\mingw32\6.3.0 -lgcc
 
#CONVERSIONE DI TMP IN BINARIO 
kernel.bin : kernel.tmp
	objcopy -O binary kernel.tmp kernel.bin
    
#CONCATENAZIONE TRA BOOTLOADER E KERNEL 
kernel_boot : btl.bin kernel.bin
	cat btl.bin kernel.bin > kernel_boot
    
#DEBUG
otp.txt : kernel.tmp
	objdump -d kernel.tmp> otp.txt