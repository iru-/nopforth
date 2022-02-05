# SPDX-License-Identifier: MIT
# Copyright (c) 2018-2022 Iruatã Martins dos Santos Souza

    .text

sysread:
    sub $(32 + 8), %rsp
    mov %rax, %rcx
    drop_
    mov %rax, %r8
    drop_
    mov %rax, %rdx
    call read
    add $(32 + 8), %rsp
    ret

syswrite:
    sub $(32 + 8), %rsp
    mov %rax, %rcx
    drop_
    mov %rax, %r8
    drop_
    mov %rax, %rdx
    call write
    add $(32 + 8), %rsp
    ret

sysexit:
    sub $(32 + 8), %rsp
    mov %rax, %rcx
    call exit

sysopen:
    sub $(32 + 8), %rsp
    mov %rax, %r8
    drop_
    mov %rax, %rdx
    drop_
    mov %rax, %rcx
    call open
    add $(32 + 8), %rsp
    ret

syscreate:
    sub $(32 + 8), %rsp
    mov %rax, %rdx
    drop_
    mov %rax, %rcx
    call creat
    add $(32 + 8), %rsp
    ret

sysclose:
    sub $(32 + 8), %rsp
    mov %rax, %rcx
    call close
    add $(32 + 8), %rsp
    ret

sysseek:
    sub $(32 + 8), %rsp
    mov %rax, %rcx
    drop_
    mov %rax, %r8
    drop_
    mov %rax, %rdx
    call lseek
    add $(32 + 8), %rsp
    ret

sysmmap:
    sub $(32 + 2*8 + 8), %rsp
    mov %rax, (5*8)(%rsp)  # offset
    drop_
    mov %rax, (4*8)(%rsp)  # fd
    drop_
    mov %rax, %r9          # flags
    drop_
    mov %rax, %r8          # prot
    drop_
    mov %rax, %rdx         # length
    drop_
    mov %rax, %rcx         # addr
    call mmap
    add $(32 + 2*8 + 8), %rsp
    ret

sysmunmap:
    sub $(32 + 8), %rsp
    mov %rax, %rdx
    drop_
    mov %rax, %rcx
    call munmap
    add $(32 + 8), %rsp
    ret

sys6:
    mov %rax, %r9
    drop_
sys5:
    mov %rax, %r8
    drop_
sys4:
    mov %rax, %r10
    drop_
sys3:
    mov %rax, %rdx
    drop_
sys2:
    mov %rax, %rsi
    drop_
sys1:
    mov %rax, %rdi
    pop %rax
    syscall
    ret

syscall6:  push %rax; drop_; jmp sys6
syscall5:  push %rax; drop_; jmp sys5
syscall4:  push %rax; drop_; jmp sys4
syscall3:  push %rax; drop_; jmp sys3
syscall2:  push %rax; drop_; jmp sys2
syscall1:  push %rax; drop_; jmp sys1

sysdlopen:
    sub $(32 + 8), %rsp
    mov %rax, %rdx
    drop_
    mov %rax, %rcx
    call dlopen
    add $(32 + 8), %rsp
    ret

sysdlsym:
    sub $(32 + 8), %rsp
    mov %rax, %rdx
    drop_
    mov %rax, %rcx
    call dlsym
    add $(32 + 8), %rsp
    ret

sysdlclose:
    sub $(32 + 8), %rsp
    mov %rax, %rcx
    call dlclose
    add $(32 + 8), %rsp
    ret

sysdlerror:
    sub $(32 + 8), %rsp
    dup_
    call dlerror
    add $(32 + 8), %rsp
    ret

_getenv:
    mov %rax, %rcx
    call getenv
    ret
