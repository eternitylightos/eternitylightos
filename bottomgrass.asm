

bgrass:
    mov edi, 0xA0000
    mov eax, 131
    mov ebx, 320
    mul ebx
    add eax, 0
    add rdi, rax

    mov al, 0x2
    mov ecx, 320
    cld
    rep stosd

    jmp $
