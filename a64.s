    .data
dstack: .space 8192, 0
dstack0: .quad 0

_R0: .quad 0    // return stack base
_S0: .quad 0    // parameter stack base
_Send: .quad 0  // parameter stack end

.macro dup_
    str x0, [fp, #-8]!
.endm

.macro drop_
    ldr x0, [fp], #8
.endm

    .data
_infd:   .quad 0  // file descriptor feeding the input
_inbuf:  .quad 0  // pointer to input buffer
_intot:  .quad 0  // input buffer total size
_inused: .quad 0  // input buffer used size
_inpos:  .quad 0  // input buffer position

    .text
    .p2align 2
type:
    stp x30, xzr, [sp, #-16]!
    mov x9, x0
    drop_
    mov x1, x0   // x1 = buffer
    mov x2, x9   // x2 = size
    mov x0, #1   // x0 = stdout
    bl write
    drop_
    ldp x30, xzr, [sp], #16
    ret

    .p2align 2
skipws:
    ldr x9, [fp]       // x9 = address
1:  cbz x0, 2f
    ldrb w10, [x9]
    cmp x10, #0x20     // ascii space
    b.gt 2f
    add x9, x9, 1
    sub x0, x0, 1
    b 1b

    .p2align 2
scanws:
    ldr x9, [fp]       // x9 = address
1:  cbz x0, 2f
    ldrb w10, [x9]
    cmp x10, #0x20     // ascii space
    b.le 2f
    add x9, x9, 1
    sub x0, x0, 1
    b 1b
2:  str x9, [fp]
    ret

    .p2align 2
source:
    adr x9, _inbuf
    ldr x9, [x9]
    adr x10, _inpos
    ldr x10, [x10]
    add x9, x9, x10     // x9 <- address of source

    adr x11, _inused
    ldr x11, [x11]
    subs x11, x11, x10  // x11 <- remaining length
    b.pl 1f             // if remaining length is negative,
    mov x11, xzr        // make it zero
1:  dup_
    mov x0, x9
    dup_
    mov x0, x11
    ret

    .p2align 2
word:
    stp x30, xzr, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    bl source
    cbz x0, 2f

    mov x20, x0        // x20 = input length
    adr x19, _inpos
    ldr x19, [x19]     // x19 = input position

    // skip leading white spaces
    bl skipws
    ldr x21, [fp]      // x21 = start of word
    sub x22, x20, x0   // x22 = consumed bytes
    add x19, x19, x22  // advance position

    // scan for next word boundary
    mov x20, x0        // x20 = remaining length
    bl scanws
    sub x0, x20, x0    // x0 = consumed bytes = word length
    add x19, x19, x0   // advance position

    adr x22, _inpos
    str x19, [x22]     // update input position
    str x21, [fp]

2:  ldp x19, x20, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x30, xzr, [sp], #16
    ret

    .p2align 2
setreadkern:
    adr x9, _kernbuf
    adr x10, _inbuf
    str x9, [x10]

    mov x9, #_kerntot
    adr x10, _intot
    str x9, [x10]
    adr x10, _inused
    str x9, [x10]

    adr x9, _inpos
    str xzr, [x9]
    ret

    .p2align 2
readloop:
    stp x30, xzr, [sp, #-16]!
1:  bl word
    cbz x0, 2f
    bl type
    b 1b
2:  drop_
    drop_
    ldp x30, xzr, [sp], #16
    ret

    .global main
    .text
    .p2align 2
main:
    bl resetstacks
    bl setreadkern
    bl readloop

spin:
    b spin

    .p2align 2
resetstacks:
    adr fp, dstack0+8
    ret

_kernbuf:
.incbin "hello.ns"
_kerntot = . - _kernbuf

