# SPDX-License-Identifier: MIT
# Copyright (c) 2021-2022 Iruatã Martins dos Santos Souza

.text
#include "arm64/boot.s"

sysexit:
    b _exit

sysopen:
    stp x30, xzr, [sp, #-16]!
    sub sp, sp, #16
    mov x9, sp
    str x0, [x9]
    drop_
    mov x1, x0
    drop_
    bl _open
    add sp, sp, #16
    ldp x30, xzr, [sp], #16
    ret

syscreate:
    stp x30, xzr, [sp, #-16]!
    mov x1, x0
    drop_
    bl _creat
    ldp x30, xzr, [sp], #16
    ret

sysclose:
    b _close

syserrno:
    stp x30, xzr, [sp, #-16]!
    dup_
    bl ___error
    ldr w0, [x0]
    ldp x30, xzr, [sp], #16
    ret

sysread:
    stp x30, xzr, [sp, #-16]!
    mov x2, x0
    drop_
    mov x1, x0
    drop_
    bl _read
    ldp x30, xzr, [sp], #16
    ret

syswrite:
    stp x30, xzr, [sp, #-16]!
    mov x2, x0
    drop_
    mov x1, x0
    drop_
    bl _write
    ldp x30, xzr, [sp], #16
    ret

sysseek:
    stp x30, xzr, [sp, #-16]!
    mov x9, x0
    drop_
    mov x2, x0
    drop_
    mov x1, x0
    mov x0, x9
    bl _lseek
    ldp x30, xzr, [sp], #16
    ret

sysmalloc:
    b _malloc

sysrealloc:
    stp x30, xzr, [sp, #-16]!
    mov x1, x0
    drop_
    bl _realloc
    ldp x30, xzr, [sp], #16
    ret

sysfree:
    stp x30, xzr, [sp, #-16]!
    bl _free
    drop_
    ldp x30, xzr, [sp], #16
    ret

sysmmap:
    stp x30, xzr, [sp, #-16]!
    mov x5, x0
    drop_
    mov x4, x0
    drop_
    mov x3, x0
    drop_
    mov x2, x0
    drop_
    mov x1, x0
    drop_
    bl _mmap
    ldp x30, xzr, [sp], #16
    ret

sysmunmap:
    stp x30, xzr, [sp, #-16]!
    mov x1, x0
    drop_
    bl _munmap
    ldp x30, xzr, [sp], #16
    ret

sysdlopen:
    stp x30, xzr, [sp, #-16]!
    mov x1, x0
    drop_
    bl _dlopen
    ldp x30, xzr, [sp], #16
    ret

sysdlsym:
    stp x30, xzr, [sp, #-16]!
    mov x1, x0
    drop_
    bl _dlsym
    ldp x30, xzr, [sp], #16
    ret

sysdlclose:
    b _dlclose

sysdlerror:
    stp x30, xzr, [sp, #-16]!
    dup_
    bl _dlerror
    ldp x30, xzr, [sp], #16
    ret

sysgetenv:
    b _getenv

setupenv:
    // setup argc, argv and environment
    sub x0, x0, 1  // discard the interpreter name
    adrp x9, _nargs@PAGE
    add x9, x9, _nargs@PAGEOFF
    str x0, [x9]
    adrp x9, _interpname@PAGE
    add x9, x9, _interpname@PAGEOFF
    str x1, [x9]
    adrp x9, _args@PAGE
    add x9, x9, _args@PAGEOFF
    add x1, x1, 8  // begin args after interpreter name
    str x1, [x9]
    ret

.data
_kernbuf:
.incbin "comments.ns"
.incbin "arm64/arch.ns"
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
