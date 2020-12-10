# SPDX-License-Identifier: MIT
# Copyright (c) 2018-2020 Iruatã Martins dos Santos Souza

    .text

# System V x86-64 ABI requires a stack aligned on a 16 bytes boundary.
# The prolog saves the return stack pointer on rbx since the latter must be
# saved by the callee, and so is guaranteed to be preserved across the call.
# Lastly, the prolog forces the stack alignment. The epilog thus restores
# the return stack pointer, which may or may not be aligned.
.macro prolog
    mov %rsp, %rbx
    and $-16, %rsp
.endm

.macro epilog
    mov %rbx, %rsp
.endm

syserrno:
    prolog
    dup_
    call __errno@plt
    mov (%rax), %eax
    movsxd %eax, %rax
    epilog
    ret

sysread:
    prolog
    mov %rax, %rdi
    drop_
    mov %rax, %rdx
    drop_
    mov %rax, %rsi
    call read@plt
    epilog
    ret

syswrite:
    prolog
    mov %rax, %rdi
    drop_
    mov %rax, %rdx
    drop_
    mov %rax, %rsi
    call write@plt
    epilog
    ret

sysexit:
    prolog
    mov %rax, %rdi
    call exit@plt

sysopen:
    prolog
    mov %rax, %rdx
    drop_
    mov %rax, %rsi
    drop_
    mov %rax, %rdi
    call open@plt
    movsxd %eax, %rax
    epilog
    ret

syscreate:
    prolog
    mov %rax, %rsi
    drop_
    mov %rax, %rdi
    call creat@plt
    movsxd %eax, %rax
    epilog
    ret

sysclose:
    prolog
    mov %rax, %rdi
    call close@plt
    movsxd %eax, %rax
    epilog
    ret

sysseek:
    prolog
    mov %rax, %rdi
    drop_
    mov %rax, %rdx
    drop_
    mov %rax, %rsi
    call lseek@plt
    epilog
    ret

sysmmap:
    prolog
    mov %rax, %r9
    drop_
    mov %rax, %r8
    drop_
    mov %rax, %rcx
    drop_
    mov %rax, %rdx
    drop_
    mov %rax, %rsi
    drop_
    mov %rax, %rdi
    call mmap@plt
    epilog
    ret

sysmunmap:
    prolog
    mov %rax, %rsi
    drop_
    mov %rax, %rdi
    call munmap@plt
    epilog
    movsxd %eax, %rax
    ret

sysalloc:
    prolog
    mov %rax, %rdi
    call malloc@plt
    epilog
    ret

sysresize:
    prolog
    mov %rax, %rsi
    drop_
    mov %rax, %rdi
    call realloc@plt
    epilog
    ret

sysfree:
    prolog
    mov %rax, %rdi
    call free@plt
    drop_
    epilog
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

_dlopen:
    prolog
    mov %rax, %rsi
    drop_
    mov %rax, %rdi
    call dlopen@plt
    epilog
    ret

_dlsym:
    prolog
    mov %rax, %rsi
    drop_
    mov %rax, %rdi
    call dlsym@plt
    epilog
    ret

_dlclose:
    prolog
    mov %rax, %rdi
    call dlclose@plt
    epilog
    ret

_dlerror:
    prolog
    dup_
    call dlerror@plt
    epilog
    ret

_getenv:
    prolog
    mov %rax, %rdi
    call getenv@plt
    epilog
    ret
