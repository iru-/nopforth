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
toupper:  // b -> b'
    cmp x0, #'a'
    b.lt 1f       // not lower case
    cmp x0, #'z'
    b.gt 1f       // not lower case
    eor x0, x0, #32
1:  ret

    .p2align 2
digit:  // b base -> b'
    stp x30, xzr, [sp, #-16]!
    mov x9, x0        // x9 = base
    drop_
    bl toupper        // normalize to upper case
    sub x0, x0, #'0'  // convert to binary
    cmp x0, #9        // is it <= 9?
    b.le 2f           // yes, go out
                      // no, number in a base > 10
    sub x0, x0, #7    // subtract the digits between '9' and 'A'
    cmp x0, #10       // is it < 10?
    mov x10, #0       // no, x10 = 0
    b.ge 1f           // yes,
    mov x10, #-1      // x10 = -1
1:  orr x0, x10, x0
2:  cmp x0, #0
    b.lt 3f
    cmp x0, x9        // is the number less than base?
    b.lt 4f           // yes, we're done
3:  mov x0, #-1       // no, it is an error
4:  ldp x30, xzr, [sp], #16
    ret

    .p2align 2
number:  // a u -> n err
    stp x30, xzr, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!

    mov x19, x0       // x19 = length
    cbz x19, 6f       // zero length string? exit
    drop_
    mov x20, x0       // x20 = string address

    ldrb w21, [x20]   // x21 = first byte
    cmp x21, #'-'     // is the number negative?
    b.ne 0f           // no, jump
    mov x22, #-1      // x22 = -1 (negative number)
    add x20, x20, 1   // advance to next byte
    sub x19, x19, 1
    b 1f

0:  mov x22, #1       // x22 = 1 (positive number)
1:  ldrb w21, [x20]
    cmp x21, #'$'     // is the number in hex?
    b.ne 2f
    mov x23, #16      // x23 = base 16
    add x20, x20, 1   // advance to next byte
    sub x19, x19, 1
    b 3f

2:  mov x23, #10      // x23 = base 10
3:  mov x24, #0       // x24 = accumulator
    mov x0, #0

4:  mul x24, x24, x23
    ldrb w0, [x20]    // x0 = current byte
    dup_
    mov x0, x23
    bl digit
    cmp x0, #0        // error converting digit? exit
    b.lt 5f
    add x24, x24, x0
    add x20, x20, 1   // advance to next byte
    subs x19, x19, 1
    b.ne 4b

    mov x0, x24
    mul x0, x24, x22  // negate result if it should be negative
5:  dup_
    mov x0, x19
6:  ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x30, xzr, [sp], #16
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

2:  ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
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

_h: .quad 0  // next dictionary address
_latest: .quad _flatest

    .text
    .p2align 2
comma:  // n ->
    adr x9, _h
    ldr x10, [x9]
    str x0, [x10], #8
    drop_
    str x10, [x9]
    ret

    .text
    .p2align 2
comma4:  // n ->
    adr x9, _h
    ldr x10, [x9]
    str w0, [x10], #4
    drop_
    str x10, [x9]
    ret

    .p2align 2
comma1:  // n ->
    adr x9, _h
    ldr x10, [x9]
    strb w0, [x10], #1
    drop_
    str x10, [x9]
    ret

    .p2align 2
move:  // src dst count ->
    mov x9, x0   // x9 = count
    drop_
    mov x10, x0  // x10 = dst
    drop_
    mov x11, x0  // x11 = src
    drop_
_move:
    cbz x9, 2f
    ldrb w12, [x11], #1
    strb w12, [x10], #1
    sub x9, x9, 1
    b _move
2:  ret

    .p2align 2
aligned:  // a -> a'
    add x0, x0, #7
    and x0, x0, #~7
    ret

    .p2align 2
entry:  // -> entry
    stp x30, xzr, [sp, #-16]!
    bl word
    ldp x30, xzr, [sp], #16

centry:  // name #name -> entry
    stp x30, xzr, [sp, #-16]!
    adr x13, _h
    ldr x13, [x13]     // x13 = entry address
    mov x14, x0        // x14 = name length

    // copy name to the correct place
    dup_
    add x15, x13, #17  // x15 = entry after link, cfa and name length
    str x15, [fp]
    bl move

    // store link
    dup_
    adr x0, _latest
    ldr x0, [x0]
    ldr x0, [x0]
    bl comma

    // store empty cfa
    dup_
    mov x0, #0
    bl comma

    // commit name
    dup_
    mov x0, x14
    bl comma1
    adr x9, _h
    add x15, x15, x14  // advance x15 past name
    str x14, [x9]      // update dictionary pointer

    // align dictionary pointer
    dup_
    mov x0, x15
    bl aligned
    adr x9, _h
    str x0, [x9]

    // update latest definition
    mov x0, x13
    adr x9, _latest
    ldr x9, [x9]
    str x0, [x9]
    ldp x30, xzr, [sp], #16
    ret

anon:  // -> a
    dup_
    adr x0, _h
    ldr x0, [x0]
    b startcomp

colon:
    stp x30, xzr, [sp, #-16]!
    bl entry
    bl anon
    mov x9, x0        // x9 = code address
    drop_             // x0 = entry address
    str x9, [x0, #8]  // store code in cfa
    drop_
    ldp x30, xzr, [sp], #16
    ret

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

startcomp:
    // search in macro then forth
    adr x9, _search
    adr x10, _mlatest
    adr x11, _flatest
    stp x10, x11, [x9]

    adr x9, _action
    adr x10, execute     // execute if found in macro
    adr x11, ccall       // compile call if found in forth
    stp x10, x11, [x9]

    adr x10, nil /*clit*/        // compile literal for numbers
    adr x11, nil /*dictrewind*/  // rewind dictionary for abort
    stp x10, x11, [x9, #16]
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

h:  // -> a
    dup_
    adr x0, _h
    ret

here:  // -> a
    dup_
    adr x0, _h
    ldr x0, [x0]
    ret

ccall:  // a ->
    stp x30, xzr, [sp, #-16]!

    // calculate call offset
    bl here
    ldr x9, [fp]
    sub x0, x9, x0

    // TODO: check if it fits in a direct branch
    asr x0, x0, #2
    and x0, x0, #0x3FFFFFF
    mov x9, #0x94000000
    orr x0, x0, x9

    ldp x30, xzr, [sp], #16
    b comma4

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
eval:  // a u -> ...
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
    b 4f

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
    b 4f

2:  mov x0, x20
    dup_
    mov x0, x19
    bl number
    cbnz x0, 3f
    drop_
    adr x9, _action
    ldr x9, [x9, #16]
    b 4f

3:  adr x9, _action
    ldr x9, [x9, #24]
    blr x9
    adr x9, abort

4:  ldp x19, x20, [sp], #16
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

    .data
dictspace: .space 8192, 0

    .text
    .p2align 2
resetdict:
    adr x9, dictspace
    adr x10, _h
    str x9, [x10]
    ret

_kernbuf:
.incbin "hello.ns"
_kerntot = . - _kernbuf

