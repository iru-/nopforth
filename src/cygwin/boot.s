# SPDX-License-Identifier: MIT
# Copyright (c) 2018-2020 Iruatã Martins dos Santos Souza

.equ PROT_READ,     0x1
.equ PROT_WRITE,    0x2
.equ PROT_EXEC,     0x4
.equ MAP_SHARED,    0x1
.equ MAP_PRIVATE,   0x2
.equ MAP_ANONYMOUS, 0x20

    .text
setupenv:
    # setup argc, argv and environment
    dec %rcx                            # discard the interpreter name
    mov %rcx, _nargs(%rip)
    mov (%rdx), %rcx
    mov %rcx, _interpname(%rip)
    lea 8(%rdx), %rcx                   # begin args after interpreter name
    mov %rcx, _args(%rip)
    ret

resetdict:
    sub $(6*8 + 8), %rsp
    dup_
    mov $0, %rcx          # addr
    mov $0x100000, %rdx   # length
    mov $(PROT_READ | PROT_WRITE | PROT_EXEC), %r8  # prot
    mov $(MAP_ANONYMOUS | MAP_SHARED), %r9          # flags
    movl $-1, (4*8)(%rsp)  # fd
    movl $0, (5*8)(%rsp)   # offset (ignored)
    call mmap
    cmp $0, %rax
    jz 1f
    mov %rax, _h(%rip)
    drop_
    add $(6*8 + 8), %rsp
    ret
1:
    mov $1, %rax
    call sysexit
