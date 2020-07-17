# frantOS

DISCLAIMER 

READ THIS README BEFORE USING THE kernelboot bin.


The kernelboot bin file, when builded, contains the mbr.asm binary + kernel_entry.asm binary + main.cpp binary.

You will need to add, in the boot drive, the "sprite_walk.bmp" at sector 50 decimal, and "houset.bmp" at sector 90 decimal. 

This bin is meant to be pasted at the sector 0 of your drive if used on a boot drive, or to be given as is to an emulator. Pasting this bin at the sector 0 of a drive will destroy the filesystem of the drive. You will be able (probably) to boot the kernelboot bin, but you will need to format the drive to use it as a data drive again. If you had files on your drive before pasting the kernelboot bin at sector 0, you will have trouble recovering this data, because there will be no filesystem in the drive acknowledging the files saved. Same is true for the two bitmap images pasted at 50 and 90 sector. 

If the "s" key is pressed, the kernelboot bin will take a screenshot of the 320*200 video memory. It will add a bmp header at the start and will save the finished image on the first ATA port, starting at sector 0xB (sector 11 in decimal). Usually, the HDD drive in connected to the fist ATA port, and the OS is written in the first sector of the drive. This means that, if you have an HDD with an operative system connected at the first ATA port, pressing the "s" key will write a ~64KB bitmap image on the operative system, destroying it. 

This toy OS was tested and used on an old 32bit desktop computer(With PCI and AGP on the motherboard!). The HDD attached on the first ATA port had no important data, so there were no problems in the writing of the HDD. 

In conclusion, be very careful using this file if you dont know what you are doing, both if you're using it on a real machine or on an emulator. keep this file away from computers or drives you have important data on.(and same is true for every other osdev/toy OS, we're talking about low level after all :) ).





What is frantOS?

First of all, frantOS is not an operative system. let's say it's a bare metal program. it's composed of 3 files:

mbr.asm
the bootloader. It load the kernel_entry.asm and main.cpp binary, and the two bitmap images in RAM. then enable the 32bit protected mode.

kernel_entry.asm
works as a main function entry for the linker, enables interrupts and implements them with IDT and some ISR.

main.cpp
mostly contain graphic manipulation functions. Bmp parsers for drawing bmp image, drawing bmp image with subtraction(removing a color showin the background), drawing only a region of a bmp image etc.
main.cpp contain some ISRs, called by the real assembly ISRs.
main.cpp contain also a simple writing ATA driver.
the main.cpp display the background images "houset.bmp", and a sprite animation made using the "sprite_walk.bmp"

The keyboard ISR contain a switch implementing some key pressing.

s key: take a screenshot of the current video memory, adding a 320*200 VGA palette header at the start, and saves it at 11 sector decimal of the primary ATA. At the end of the writing, the primary ATA sends an interrupt that stop the sprite animation.

g key: toggle a square in the middle of the screen. It's black by default.

1 to 9 keys: they change the color of the square. Each key corresponds to the VGA palette value of it's number(e.g if you press the 2 key, the color will be the one at position 2 in the VGA palette)

[This youtube video shows how frantOS works](https://www.youtube.com/watch?v=cCilnmk6WnE)


![Alt text](https://i.imgur.com/Z4PX7nU.png)


