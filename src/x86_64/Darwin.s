# SPDX-License-Identifier: MIT
# Copyright (c) 2018-2022 Iruatã Martins dos Santos Souza

    .text
.include "boot.s"

.equ PROT_READ,     0x1
.equ PROT_WRITE,    0x2
.equ PROT_EXEC,     0x4
.equ MAP_SHARED,    0x1
.equ MAP_PRIVATE,   0x2
.equ MAP_ANONYMOUS, 0x1000

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
    call ___error
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
    call _read
    epilog
    ret

syswrite:
    prolog
    mov %rax, %rdi
    drop_
    mov %rax, %rdx
    drop_
    mov %rax, %rsi
    call _write
    epilog
    ret

sysexit:
    prolog
    mov %rax, %rdi
    call _exit

sysopen:
    prolog
    mov %rax, %rdx
    drop_
    mov %rax, %rsi
    drop_
    mov %rax, %rdi
    call _open
    movsx %eax, %rax
    epilog
    ret

syscreate:
    prolog
    mov %rax, %rsi
    drop_
    mov %rax, %rdi
    call _creat
    movsx %eax, %rax
    epilog
    ret

sysclose:
    prolog
    mov %rax, %rdi
    call _close
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
    call _lseek
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
    call _mmap
    epilog
    ret

sysmunmap:
    prolog
    mov %rax, %rsi
    drop_
    mov %rax, %rdi
    call _munmap
    epilog
    movsx %eax, %rax
    ret

sysalloc:
    prolog
    mov %rax, %rdi
    call _malloc
    epilog
    ret

sysresize:
    prolog
    mov %rax, %rsi
    drop_
    mov %rax, %rdi
    call _realloc
    epilog
    ret

sysfree:
    prolog
    mov %rax, %rdi
    call _free
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
    call _dlopen
    epilog
    ret

sysdlsym:
    prolog
    mov %rax, %rsi
    drop_
    mov %rax, %rdi
    call _dlsym
    epilog
    ret

sysdlclose:
    prolog
    mov %rax, %rdi
    call _dlclose
    epilog
    ret

sysdlerror:
    prolog
    dup_
    call _dlerror
    epilog
    ret

sysgetenv:
    prolog
    mov %rax, %rdi
    call _getenv
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

resetdict:
    dup_
    mov $0, %rdi         # addr
    mov $0x100000, %rsi  # length
    mov $(PROT_READ | PROT_WRITE | PROT_EXEC), %rdx  # prot
    mov $(MAP_ANONYMOUS | MAP_SHARED), %rcx          # flags
    mov $-1, %r8         # fd
    mov $0, %r9          # offset (ignored)
    call _mmap
    test %rax, %rax
    jz 1f
    mov %rax, _h(%rip)
    drop_
    ret
1:
    mov $1, %rax
    call sysexit

.data
.include "dicts.s"

_kernbuf:
.incbin "comments.ns"
.incbin "arch.ns"
.incbin "flowcontrol.ns"
.incbin "interactive.ns"
.incbin "dictionary.ns"
.incbin "memory.ns"
.incbin "string.ns"
.incbin "pictured.ns"
.incbin "interpreter.ns"
.incbin "file.ns"
.incbin "shell.ns"
.incbin "loadpaths.ns"
.incbin "go.ns"
_kerntot = . - _kernbuf
