[BITS 64]
kmain:

    mov rdi, 0xA0000
    mov al, 0x9
    mov rcx, 64000

    cld
    rep stosb

    mov al, 0x0
    mov ecx, 320
    cld
    rep stosb
    rep movsd
    %include "bottomgrass.asm"





