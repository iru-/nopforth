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
skipws:  // a u -> a' u'
    ldr x9, [fp]       // x9 = address
1:  cbz x0, 2f
    ldrb w10, [x9]
    cmp x10, #0x20     // ascii space
    b.gt 2f
    add x9, x9, 1
    sub x0, x0, 1
    b 1b

    .p2align 2
scanws:  // a u -> a' u'
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
source:  // -> a u
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
word:  // -> a u
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


    .data
hellostr: .ascii "hello"
          .byte '\n'
hellolen= . - hellostr
    .text
hello:
    dup_
    adr x0, hellostr
    dup_
    mov x0, hellolen
    b type

    .data
    .align 8
end_header:
    .quad 0
    .quad 0
    .byte 3
    .ascii "end"

    .align 8
hello_header:
    .quad end_header
    .quad hello
    .byte 5
    .ascii "hello"

_flatest: .quad hello_header
_mlatest: .quad 0

    .text
    .p2align 2
stopcomp:
    // search in forth then macro
    adr x9, _search
    adr x10, _flatest
    adr x11, _mlatest
    stp x10, x11, [x9]

    adr x9, _action
    // execute if found in any of the dicts
    adr x10, execute
    stp x10, x10, [x9]
    // do nothing for numbers and abort
    adr x10, nil
    stp x10, x10, [x9, #16]
    ret

    .p2align 2
dfind:  // name #name dict -> entry
    mov x9, x0            // x9 = dict
    drop_
    mov x10, x0           // x10 = string count
    drop_
    mov x11, x0           // x11 = string address

1:  cbnz x9, 2f           // end of dict?
    mov x0, #0            // yes, no entry found
    ret

2:  ldrb w12, [x9, #16]   // x12 = name length
    cmp x12, x10          // are lengths equal?
    b.ne 5f               // no, stop comparison
                          // yes, compare contents
    add x13, x9, #17      // x13 = name pointer
    mov x16, #0           // x16 = offset

3:  cbnz x12, 4f          // is comparison over?
    mov x0, x9            // yes, return entry
    ret

4:  ldrb w14, [x13, x16]  // x14 = byte from string
    ldrb w15, [x11, x16]  // x15 = byte from name
    cmp x14, x15
    b.ne 5f               // if equal, continue comparing
    add x16, x16, 1       // advance offset
    sub x12, x12, 1
    b 3b

5:  ldr x9, [x9]          // load previous dict entry
    b 1b

    .data
_qmsg:  .ascii "?\n"
_qlen = . - _qmsg
    .text
    .p2align 2
abort:
    stp x30, xzr, [sp, #-16]!
    dup_
    adr x0, _inbuf
    ldr x0, [x0]
    dup_
    adr x0, _inpos
    ldr x0, [x0]
    bl type
    dup_
    adr x0, _qmsg
    dup_
    mov x0, #_qlen
    bl type
    bl resetinput
    bl resetstacks
    ldp x30, xzr, [sp], #16
    b warm

    .data
_search:
  .quad 0          // 1st dictionary to be searched
  .quad 0          // 2nd dictionary to be searched
_action:
  .quad 0          // action on 1st search found
  .quad 0          // action on 2nd search found
  .quad nil        // action on number found
  .quad nil        // abort action

    .text
    .p2align 2
nil: ret

    .p2align 2
eval:  // a u ->
    stp x30, xzr, [sp, #-16]!
    stp x19, x20, [sp, #-16]!

    mov x19, x0       // x19 = string length
    ldr x20, [fp]     // x20 = string address

    dup_
    adr x0, _search
    ldr x0, [x0]
    bl dfind
    cbz x0, 1f        // entry not found, continue
    add x0, x0, #8    // get CFA
    ldr x0, [x0]
    adr x9, _action
    ldr x9, [x9]
    b 3f

1:  mov x0, x20
    dup_
    mov x0, x19
    dup_
    adr x0, _search
    ldr x0, [x0, #8]
    bl dfind
    cbz x0, 2f        // entry not found, continue
    add x0, x0, #8    // get CFA
    ldr x0, [x0]
    adr x9, _action
    ldr x9, [x9, #8]
    b 3f

2:  adr x9, _action
    ldr x9, [x9, #24]
    blr x9
    adr x9, abort

3:  ldp x19, x20, [sp], #16
    ldp x30, xzr, [sp], #16
    br x9

    .p2align 2
execute:
    mov x9, x0
    drop_
    br x9

    .p2align 2
resetinput:
    mov x9, #0
    adr x10, _inused
    adr x11, _inpos
    str x9, [x10]
    str x9, [x11]
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
    bl eval
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
    bl stopcomp
    bl setreadkern
warm:
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

