[bits 32]
[extern _KERNEL_START] ;_bc]
[extern _ATA_ack]
[extern _exc_ack]
[extern _keyb_irq]

ADDR_CONST equ 0x1000

lidt [idt_descr]

;SET PIC
mov al, 0x11
out 0x20, al
out 0xA0, al

mov al, 40
out 0x21, al
mov al, 32
out 0xA1, al

mov al, 0x4
out 0x21, al
mov al, 0x2
out 0xA1, al

;ICW4
mov al, 0x0
out 0x21, al
out 0xA1, al

;MASK
mov al, 0x1
out 0x21, al
mov al, 0x0
out 0xA1, al


sti

jmp _KERNEL_START

;in case of error, print a red pixel on top left corner
mov [0xa0000], byte 4
cli
hlt


;INTERRUPT SERVICE ROUTINES
;-----------------------------------------------------
timer_handler:

pushad

mov al, 0x20
out 0x20, al

mov al, 0xA0
out 0x20, al

popad

iret
;-----------------------------------------------------
isr_keyboard:

pushad

call _keyb_irq

mov al, 0x20
out 0x20, al

mov al, 0xA0
out 0x20, al

popad


iret
;-----------------------------------------------------
ATA_handler:

pushad

call _ATA_ack

mov al, 0x20
out 0x20, al

mov al, 0xA0
out 0x20, al

popad

iret
;-----------------------------------------------------
exception_handler:

pushad

call _exc_ack

popad

cli
hlt
;-----------------------------------------------------
hwi_handler:

pushad

mov al, 0x20
out 0x20, al

mov al, 0xA0
out 0x20, al

popad

iret
;-----------------------------------------------------
swi_handler:

pushad
popad

iret

;---DATA STRUCTURES---

;IDT

;offseta_1  dw 0x0
;selector   dw 0x0
;zero       db 0x0
;type_attr  db 0x0
;offsetb_1  dw 0x0

;allocate 400 byte(50 irs descriptor)
idt_start:
dw (ADDR_CONST + exception_handler - $$) & 0xFFFF ;Divide-by-zero Error
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + exception_handler - $$) >> 16
;-------
dw (ADDR_CONST + exception_handler - $$) & 0xFFFF ;Debug
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + exception_handler - $$) >> 16
;-------
dw (ADDR_CONST + exception_handler - $$) & 0xFFFF ;Non-maskable Interrupt
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + exception_handler - $$) >> 16
;-------
dw (ADDR_CONST + exception_handler - $$) & 0xFFFF ;Breakpoint
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + exception_handler - $$) >> 16
;-------
dw (ADDR_CONST + exception_handler - $$) & 0xFFFF ;Overflow
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + exception_handler - $$) >> 16
;-------
dw (ADDR_CONST + exception_handler - $$) & 0xFFFF ;Bound Range Exceeded
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + exception_handler - $$) >> 16
;-------
dw (ADDR_CONST + exception_handler - $$) & 0xFFFF ;Invalid Opcode
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + exception_handler - $$) >> 16
;-------
dw (ADDR_CONST + exception_handler - $$) & 0xFFFF ;Device Not Available
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + exception_handler - $$) >> 16
;-------
dw (ADDR_CONST + exception_handler - $$) & 0xFFFF ;Double Fault
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + exception_handler - $$) >> 16
;-------
dw (ADDR_CONST + exception_handler - $$) & 0xFFFF ;Coprocessor Segment Overrun(deleted on osdev)
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + exception_handler - $$) >> 16
;-------first 10 isr
dw (ADDR_CONST + exception_handler - $$) & 0xFFFF ;Invalid TSS
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + exception_handler - $$) >> 16
;-------
dw (ADDR_CONST + exception_handler - $$) & 0xFFFF ;Segment Not Present
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + exception_handler - $$) >> 16
;-------
dw (ADDR_CONST + exception_handler - $$) & 0xFFFF ;Stack-Segment Fault
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + exception_handler - $$) >> 16
;-------
dw (ADDR_CONST + exception_handler - $$) & 0xFFFF ;General Protection Fault
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + exception_handler - $$) >> 16
;-------
dw (ADDR_CONST + exception_handler - $$) & 0xFFFF ;Page Fault
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + exception_handler - $$) >> 16
;-------
dw (ADDR_CONST + exception_handler - $$) & 0xFFFF ;Reserved
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + exception_handler - $$) >> 16
;-------
dw (ADDR_CONST + exception_handler - $$) & 0xFFFF ;x87 Floating-Point Exception
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + exception_handler - $$) >> 16
;-------
dw (ADDR_CONST + exception_handler - $$) & 0xFFFF ;Alignment Check
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + exception_handler - $$) >> 16
;-------
dw (ADDR_CONST + exception_handler - $$) & 0xFFFF ;Machine Check
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + exception_handler - $$) >> 16
;-------
dw (ADDR_CONST + exception_handler - $$) & 0xFFFF ;SIMD Floating-Point Exception
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + exception_handler - $$) >> 16
;-------first 20 isr
dw (ADDR_CONST + exception_handler - $$) & 0xFFFF ;Virtualization Exception
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + exception_handler - $$) >> 16
;-------
dw (ADDR_CONST + exception_handler - $$) & 0xFFFF ;Reserved
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + exception_handler - $$) >> 16
;-------
dw (ADDR_CONST + exception_handler - $$) & 0xFFFF ;Reserved
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + exception_handler - $$) >> 16
;-------
dw (ADDR_CONST + exception_handler - $$) & 0xFFFF ;Reserved
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + exception_handler - $$) >> 16
;-------
dw (ADDR_CONST + exception_handler - $$) & 0xFFFF ;Reserved
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + exception_handler - $$) >> 16
;-------
dw (ADDR_CONST + exception_handler - $$) & 0xFFFF ;Reserved
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + exception_handler - $$) >> 16
;-------
dw (ADDR_CONST + exception_handler - $$) & 0xFFFF ;Reserved
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + exception_handler - $$) >> 16
;-------
dw (ADDR_CONST + exception_handler - $$) & 0xFFFF ;Reserved
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + exception_handler - $$) >> 16
;-------
dw (ADDR_CONST + exception_handler - $$) & 0xFFFF ;Reserved
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + exception_handler - $$) >> 16
;-------
dw (ADDR_CONST + exception_handler - $$) & 0xFFFF ;Reserved
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + exception_handler - $$) >> 16
;-------first 30 isr
dw (ADDR_CONST + exception_handler - $$) & 0xFFFF ;Security Exception
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + exception_handler - $$) >> 16
;-------
dw (ADDR_CONST + exception_handler - $$) & 0xFFFF ;Reserved
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + exception_handler - $$) >> 16
;-------
dw (ADDR_CONST + hwi_handler - $$) & 0xFFFF ;CMOS real-time clock
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + hwi_handler - $$) >> 16
;-------
dw (ADDR_CONST + hwi_handler - $$) & 0xFFFF ;Free for peripherals / legacy SCSI / NIC
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + hwi_handler - $$) >> 16
;-------
dw (ADDR_CONST + hwi_handler - $$) & 0xFFFF ;Free for peripherals / SCSI / NIC
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + hwi_handler - $$) >> 16
;-------
dw (ADDR_CONST + hwi_handler - $$) & 0xFFFF ;Free for peripherals / SCSI / NIC
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + hwi_handler - $$) >> 16
;-------
dw (ADDR_CONST + hwi_handler - $$) & 0xFFFF ;PS2 Mouse
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + hwi_handler - $$) >> 16
;-------
dw (ADDR_CONST + hwi_handler - $$) & 0xFFFF ;FPU / Coprocessor / Inter-processor
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + hwi_handler - $$) >> 16
;-------
dw (ADDR_CONST + ATA_handler - $$) & 0xFFFF ;Primary ATA Hard Disk
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + ATA_handler - $$) >> 16
;-------
dw (ADDR_CONST + hwi_handler - $$) & 0xFFFF ;Secondary ATA Hard Disk
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + hwi_handler - $$) >> 16
;-------first 40 isr
dw (ADDR_CONST + timer_handler - $$) & 0xFFFF ;Programmable Interrupt Timer Interrupt
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + timer_handler - $$) >> 16
;-------
dw (ADDR_CONST + isr_keyboard - $$) & 0xFFFF ;Keyboard Interrupt
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + isr_keyboard - $$) >> 16
;-------
dw (ADDR_CONST + hwi_handler - $$) & 0xFFFF ;Cascade (used internally by the two PICs. never raised)
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + hwi_handler - $$) >> 16
;-------
dw (ADDR_CONST + hwi_handler - $$) & 0xFFFF ;COM2 (if enabled)
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + hwi_handler - $$) >> 16
;-------
dw (ADDR_CONST + hwi_handler - $$) & 0xFFFF ;COM1 (if enabled)
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + hwi_handler - $$) >> 16
;-------
dw (ADDR_CONST + hwi_handler - $$) & 0xFFFF ;LPT2 (if enabled)
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + hwi_handler - $$) >> 16
;-------
dw (ADDR_CONST + hwi_handler - $$) & 0xFFFF ;Floppy Disk
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + hwi_handler - $$) >> 16
;-------
dw (ADDR_CONST + hwi_handler - $$) & 0xFFFF ;LPT1 / Unreliable "spurious" interrupt (usually)
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + hwi_handler - $$) >> 16
;-------
dw (ADDR_CONST + swi_handler - $$) & 0xFFFF ;free slot interrupt
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + swi_handler - $$) >> 16
;-------
dw (ADDR_CONST + swi_handler - $$) & 0xFFFF ;free slot interrupt
dw 0x8
db 0x0
db 0x8E
dw (ADDR_CONST + swi_handler - $$) >> 16
;-------first 50 isr

;PIC hardware interrupt
idt_end:

;IDT DESCR
idt_descr:
  dw idt_end - idt_start
  dd idt_start


dw 0x77EE ;signature showing end of kernel entry file, for debug purpose.
