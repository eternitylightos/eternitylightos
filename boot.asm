

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
    mov [.bdrive], dl
    cld

    call CheckCPU ;check cpu for 64bit
    jc .NoLongMode

.load_disk:

    mov ah, 0
    int 0x13
    jc .disk_error


    mov ah, 0x02
    mov al, 2
    mov ch, 0
    mov dh, 0
    mov cl, 2
    mov bx, 0x7e00
    int 0x13

    jnc .disk_success


    dec di
    jz .disk_error
    xor ax, ax
    int 0x13
    jmp .load_disk

.disk_success:
    jmp 0x7e00

.disk_error:
    mov ax, 0x3 ;VGA text mode
    int 0x10 ;video services
    mov si, .msg ;moving the disk_error msg to SI
.disk_print:

    mov al, [si]
    cmp al, 0
    je .done

    mov ah, 0x0E
    mov bx, 0x0007
    int 0x10
    inc si
    jmp .disk_print
.msg: db "disk_error", 0
.bdrive db 0

.done:






[BITS 64]
.Long:

    hlt
    jmp .Long
    mov ax, 0x3
    int 10h
[BITS 16]

.NoLongMode:
    mov si, NoLongMode
    mov ax, 0x3
    int 10h
    call print

.halt:
    hlt
    jmp .halt

;%include "longMode.asm"
[BITS 16]

NoLongMode db "64bit>CPU ", 0x0A, 0x0D, 0

CheckCPU:
    pushfd

    pop eax
    int 10h
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
;next sector
    mov ax, 0x13 ;vga vid mode
    int 0x10 ;vid services
    jmp $


times 1024 - ($-$$) db 0 ; padding
