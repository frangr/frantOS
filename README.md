# frantOS

DISCLAIMER 

READ THIS README BEFORE USING THE kernelboot bin.


The kernelboot bin file, when builded, contains the mbr.asm binary + kernel_entry.asm binary + main.cpp binary.

You will need to add, in the boot drive, the "sprite_walk.bmp" at sector 50 decimal, and "houset.bmp" at sector 90 decimal. 

This bin is meant to be pasted at the sector 0 of your drive if used on a boot drive, or to be given as is to an emulator. Pasting this bin at the sector 0 of a drive will destroy the filesystem of the drive. You will be able (probably) to boot the kernelboot bin, but you will need to format the drive to use it as a data drive again. If you had files on your drive before pasting the kernelboot bin at sector 0, you will have trouble recovering this data, because there will be no filesystem in the drive acknowledging the files saved. Same is true for the two bitmap images pasted at 50 and 90 sector. 

If the "g" key is pressed, the kernelboot bin will take a screenshot of the 320*200 video memory. It will add a bmp header at the start and will save the finished image on the first ATA port, starting at sector 0xB (sector 11 in decimal). Usually, the HDD drive in connected to the fist ATA port, and the OS is written in the first sector of the drive. This means that, if you have an HDD with an operative system connected at the first ATA port, pressing the "g" key will write a ~64KB bitmap image on the operative system, destroying it. 

This toy OS was tested and used on an old 32bit desktop computer(With PCI and AGP on the motherboard!). The HDD attached on the first ATA port had no important data, so there were no problems in the writing of the HDD. 

In conclusion, be very careful using this file if you dont know what you are doing, both if you're using it on a real machine or on an emulator. keep this file away from computers or drives you have important data on.(and same is true for every other osdev/toy OS, we're talking about low level after all :) ).
