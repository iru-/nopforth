# SPDX-License-Identifier: MIT
# Copyright (c) 2018-2020 Iruatã Martins dos Santos Souza

.equ PROT_READ,     0x1
.equ PROT_WRITE,    0x2
.equ PROT_EXEC,     0x4
.equ MAP_SHARED,    0x1
.equ MAP_PRIVATE,   0x2
.equ MAP_ANONYMOUS, 0x1000

    .text
setupenv:
    # setup argc, argv and environment
    dec %rdi                       # discard the interpreter name
    mov %rdi, _nargs(%rip)
    mov (%rsi), %rcx
    mov %rcx, _interpname(%rip)
    lea 8(%rsi), %rcx              # begin args after interpreter name
    mov %rcx, _args(%rip)
    ret

resetdict:
    dup_
    mov $0, %rdi         # addr
    mov $0x100000, %rsi  # length
    mov $(PROT_READ | PROT_WRITE | PROT_EXEC), %rdx  # prot
    mov $(MAP_ANONYMOUS | MAP_SHARED), %rcx          # flags
    mov $-1, %r8         # fd
    mov $0, %r9          # offset (ignored)
    call mmap@plt
    jz 1f
    mov %rax, _h(%rip)
    drop_
    ret
1:
    mov $1, %rax
    call sysexit
