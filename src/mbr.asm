[bits 16]
[org 0x7c00]

addr equ 0x1000
im_addr equ 0x7E00
backg_addr equ 0xBC50
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

;16 BIT INIT
mov bx,0x0
mov es, bx
mov ds, bx
clc

;CARICA KERNEL IN RAM
mov eax, 0x1
mov [drive_adr], eax

mov ax, 0x2A ;0x19
mov [sec_num], eax

mov eax, addr
mov [Daddr], eax

mov si, 0x0+DAP
mov dl, 0x80
mov ah, 0x42 ;41h ;problema
int 0x13

;CARICA IMMAGINE IN RAM-----------------------------------------------------

;primo settore(n. 50)
mov eax, 0x32
mov [drive_adr], eax

;settori da caricare in ram(175)
mov ax, 0xB5 ;0xB1 ;0x174
mov [sec_num], eax

;indirizzo ram in cui caricare immagine(0x7E00)
mov eax, im_addr
mov [Daddr], eax

mov si, 0x0+DAP
mov dl, 0x80
mov ah, 0x42 ;41h ;problema
int 0x13

;CARICA SFONDO IN RAM------------------------------------------------------------
mov eax, 0x5A
mov [drive_adr], eax

mov ax, 0x80 ;0x19
mov [sec_num], eax

mov eax, backg_addr
mov [Daddr], eax

mov si, 0x0+DAP
mov dl, 0x80
mov ah, 0x42 ;41h ;problema
int 0x13

jc err

;VIDEO MODE SELECT
mov ah, 0x0
mov al, 0x13;3
int 0x10

;32 BIT PROTECTED MODE
cli

lgdt [gdt_descr]

mov eax, cr0
or eax, 0x1
mov cr0, eax


jmp CODE_SEG:protected_mode_jmp


;ORA IN PROTECTED MODE

[bits 32]

protected_mode_jmp:

  jmp addr
  hlt

err:
    mov ah , 0x0e
    mov al, 'e' ;ch
    int 0x10
    hlt







;DATA-------------------------------------------------------------------
gdt_start:

;null descriptor
gdt_null:
  dd 0x0
  dd 0x0

;code segment
gdt_code:
  dw 0xffff
  dw 0x0
  db 0x0
  db 10011010b
  db 11001111b
  db 0x0

;data segment
gdt_data:
  dw 0xffff
  dw 0x0
  db 0x0
  db 10010010b
  db 11001111b
  db 0x0

gdt_end:

gdt_descr:
  dw gdt_end - gdt_start - 1 ;GDT size
  dd gdt_start ;GDT start address


DAP:
    ;DPA
    db 0x10 ;grandezza del pacchetto
    db 0x0  ;sempre 0
    sec_num dw 0;A  ;numero di settori da leggere/scrivere 0x19
    ;address in RAM
    Daddr dd 0 ;indirizzo in cui caricare settori/prendere dati RAM da scrivere
    ;address LBA del drive
    drive_adr dq 0 ;indirizzo drive da cui caricare/su cui scrivere

    times ((510) - ($ - $$)) db 0x00
    dw 0xAA55
