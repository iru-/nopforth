.text
#include "arm64/boot.s"

sysopen:
    stp x30, xzr, [sp, #-16]!
    mov x2, x0
    drop_
    mov x1, x0
    drop_
    bl _open
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

sysread:
    stp x30, xzr, [sp, #-16]!
    mov x9, x0
    drop_
    mov x2, x0
    drop_
    mov x1, x0
    mov x0, x9
    bl _read
    ldp x30, xzr, [sp], #16
    ret

syswrite:
    stp x30, xzr, [sp, #-16]!
    mov x9, x0
    drop_
    mov x2, x0
    drop_
    mov x1, x0
    mov x0, x9
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
_kerntot = . - _kernbuf
