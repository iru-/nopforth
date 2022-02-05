# SPDX-License-Identifier: MIT
# Copyright (c) 2018-2022 Iruatã Martins dos Santos Souza

.equ PROT_READ,     0x1
.equ PROT_WRITE,    0x2
.equ PROT_EXEC,     0x4
.equ MAP_SHARED,    0x1
.equ MAP_PRIVATE,   0x2

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
    call errnoaddr@plt
    mov (%rax), %eax
    movsx %eax, %rax
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
    movsx %eax, %rax
    epilog
    ret

syscreate:
    prolog
    mov %rax, %rsi
    drop_
    mov %rax, %rdi
    call creat@plt
    movsx %eax, %rax
    epilog
    ret

sysclose:
    prolog
    mov %rax, %rdi
    call close@plt
    movsx %eax, %rax
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
    movsx %eax, %rax
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

sysdlopen:
    prolog
    mov %rax, %rsi
    drop_
    mov %rax, %rdi
    call dlopen@plt
    epilog
    ret

sysdlsym:
    prolog
    mov %rax, %rsi
    drop_
    mov %rax, %rdi
    call dlsym@plt
    epilog
    ret

sysdlclose:
    prolog
    mov %rax, %rdi
    call dlclose@plt
    epilog
    ret

sysdlerror:
    prolog
    dup_
    call dlerror@plt
    epilog
    ret

sysgetenv:
    prolog
    mov %rax, %rdi
    call getenv@plt
    epilog
    ret

setupenv:
    # setup argc, argv and environment
    dec %rdi                       # discard the interpreter name
    mov %rdi, _nargs(%rip)
    mov (%rsi), %rcx
    mov %rcx, _interpname(%rip)
    lea 8(%rsi), %rcx              # begin args after interpreter name
    mov %rcx, _args(%rip)
    ret

    .data
_dictstart: .quad 0
_dictsize = 0x100000
_codestart: .quad 0
_codesize = 0x100000

    .text
resetdict:
    // dictionary
    dup_
    mov $_dictsize, %rdi
    call malloc@plt
    test %rax, %rax
    jz 1f
    mov %rax, _h(%rip)
    mov %rax, _dictstart(%rip)

    // code space
    mov $0, %rdi          # addr
    mov $_codesize, %rsi  # length
    mov $(PROT_READ | PROT_WRITE | PROT_EXEC), %rdx  # prot
    mov $(MAP_ANONYMOUS | MAP_SHARED), %rcx          # flags
    mov $-1, %r8          # fd
    mov $0, %r9           # offset (ignored)
    call mmap@plt
    cmp $-1, %rax         # MAP_FAILED?
    je 1f
    mov %rax, codepp(%rip)
    mov %rax, _codestart(%rip)
    drop_
    ret
1:
    mov $1, %rax
    jmp sysexit
