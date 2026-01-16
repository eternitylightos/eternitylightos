

%define FREE_SPACE 0x9000
[ORG 0x7C00]
[BITS 16]



Main:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00

    mov ax, 0x13 ;video mode 13h
    int 10h ;video services
    mov ax, 0A0000h
    mov es, ax
    jmp 0x0000:.flush


.flush:
    xor ax, ax

    mov ss, ax

    mov sp, Main

    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    cld

    call CheckCPU ;check cpu for 64bit
    jc .NoLongMode

    mov edi, FREE_SPACE

    jmp Switch



[BITS 64]
.Long:

    hlt
    jmp .Long

[BITS 16]

.NoLongMode:
    mov si, NoLongMode
    mov ax, 0x3
    int 10h
    call print

.halt:
    hlt
    jmp .halt

%include "longMode.asm"
[BITS 16]

NoLongMode db "64bit>CPU ", 0x0A, 0x0D, 0

CheckCPU:
    pushfd

    pop eax
    mov ecx, eax
    xor eax, 0x200000
    push eax
    popfd

    pushfd
    pop eax
    xor eax, ecx
    shr eax, 21
    and eax, 1
    push ecx
    popfd

    test eax, eax
    jz .NoLongMode

    mov eax, 0x80000000
    cpuid

    cmp eax, 0x80000001
    jb .NoLongMode

    mov eax, 0x80000001
    cpuid
    test edx, 1 << 29
    jz .NoLongMode

    ret

.NoLongMode:
    stc
    ret

print:
    pushad
.PrintLoop:
    lodsb
    test al, al
    je .PrintDone
    mov ah, 0x0E
    int 0x10
    jmp .PrintLoop

.PrintDone:
    popad
    ret

times 510 - ($-$$) db 0
dw 0xAA55


