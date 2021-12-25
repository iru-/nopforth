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

// Darwin
.equ PROT_READ,     0x1
.equ PROT_WRITE,    0x2
.equ PROT_EXEC,     0x4

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
    bl _write
    drop_
    ldp x30, xzr, [sp], #16
    ret

skipws:  // a u -> a' u'
    ldr x9, [fp]       // x9 = address
1:  cbz x0, 2f
    ldrb w10, [x9]
    cmp x10, #0x20     // ascii space
    b.gt 2f
    add x9, x9, 1
    sub x0, x0, 1
    b 1b

skip:  // a u delim -> a' u'
    mov x10, x0    // x10 = delim
    drop_          // x0 = length
    ldr x9, [fp]   // x9 = address
1:  cbz x0, 2f
    ldrb w11, [x9] // w11 = current byte
    cmp w11, w10
    b.ne 2f
    add x9, x9, 1
    sub x0, x0, 1
    b 1b
2:  str x9, [fp]
    ret

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

scan:  // a u delim -> a' u'
    mov x10, x0    // x10 = delim
    drop_          // x0 = length
    ldr x9, [fp]   // x9 = address
1:  cbz x0, 2f
    ldrb w11, [x9] // w11 = current byte
    cmp w11, w10
    b.eq 2f
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
    adrp x9, _inbuf@PAGE
    add x9, x9, _inbuf@PAGEOFF
    ldr x9, [x9]
    adrp x10, _inpos@PAGE
    add x10, x10, _inpos@PAGEOFF
    ldr x10, [x10]
    add x9, x9, x10     // x9 <- address of source

    adrp x11, _inused@PAGE
    add x11, x11, _inused@PAGEOFF
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
    adrp x19, _inpos@PAGE
    add x19, x19, _inpos@PAGEOFF
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

    adrp x22, _inpos@PAGE
    add x22, x22, _inpos@PAGEOFF
    str x19, [x22]     // update input position
    str x21, [fp]

2:  ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x30, xzr, [sp], #16
    ret

parse:  // delim -> a u
    stp x30, xzr, [sp, #-16]!
    mov x19, x0                 // x19 = delimiter
    drop_
    bl source

    cbz x0, 2f                  // return on end of input
    mov x21, x0                 // x21 = length
    ldr x20, [fp]               // x20 = address
    dup_
    mov x0, x19
    bl scan

    ldr x11, [fp]
    ldrb w11, [x11]             // x11 = last byte scanned
    sub x21, x21, x0            // x21 = consumed bytes
    adrp x9, _inpos@PAGE
    add x9, x9, _inpos@PAGEOFF
    ldr x10, [x9]               // x10 = inpos

    cmp x11, x19                // did we scan a delimiter?
    b.ne 1f                     // no
    add x21, x21, #1            // yes, consume delimiter

1:  add x0, x21, x10            // x0 = inpos + consumed bytes
    str x0, [x9]                // update inpos
    mov x0, x21
    str x20, [fp]
2:  ldp x30, xzr, [sp], #16
    ret

    .data
hellostr: .ascii "hello"
          .byte '\n'
hellolen= . - hellostr
    .text
hello:
    dup_
    adrp x0, hellostr@PAGE
    add x0, x0, hellostr@PAGEOFF
    dup_
    mov x0, hellolen
    b type

bye:
    mov x0, #0
    b _exit

    .data
    .align 8
end_header:
    .quad 0
    .quad 0
    .byte 3
    .ascii "end"

    .align 8
type_header:
    .quad end_header
    .quad type
    .byte 4
    .ascii "type"

    .align 8
parse_header:
    .quad type_header
    .quad parse
    .byte 5
    .ascii "parse"

    .align 8
Br_header:
    .quad parse_header
    .quad Br
    .byte 2
    .ascii "Br"

    .align 8
hello_header:
    .quad Br_header
    .quad hello
    .byte 5
    .ascii "hello"

    // macro
    .align 8
colon_header:
    .quad 0
    .quad colon
    .byte 1
    .ascii ":"

    .align 8
semicolon_header:
    .quad colon_header
    .quad semicolon
    .byte 1
    .ascii ";"

    .align 8
stopcomp_header:
    .quad semicolon_header
    .quad stopcomp
    .byte 1
    .ascii "["

    .p2align 3
flatestp: .quad hello_header
mlatestp: .quad stopcomp_header
latestp: .quad flatestp

_h: .quad 0   // next code address
_dp: .quad 0  // next dictionary address

    .text
    .p2align 2
flatest:
    dup_
    adrp x0, flatestp@PAGE
    add x0, x0, flatestp@PAGEOFF
    ret

    .p2align 2
mlatest:
    dup_
    adrp x0, mlatestp@PAGE
    add x0, x0, mlatestp@PAGEOFF
    ret

    .p2align 2
latest:
    dup_
    adrp x0, latestp@PAGE
    add x0, x0, latestp@PAGEOFF
    ret

    .p2align 2
comma:  // n ->
    adrp x9, _h@PAGE
    add x9, x9, _h@PAGEOFF
    ldr x10, [x9]
    str x0, [x10], #8
    drop_
    str x10, [x9]
    ret

    .text
    .p2align 2
comma4:  // n ->
    adrp x9, _h@PAGE
    add x9, x9, _h@PAGEOFF
    ldr x10, [x9]
    str w0, [x10], #4
    drop_
    str x10, [x9]
    ret

    .p2align 2
comma1:  // n ->
    adrp x9, _h@PAGE
    add x9, x9, _h@PAGEOFF
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
    adrp x13, _dp@PAGE
    add x13, x13, _dp@PAGEOFF
    ldr x13, [x13]     // x13 = entry address
    mov x14, x0        // x14 = name length

    // store link
    adrp x9, latestp@PAGE
    add x9, x9, latestp@PAGEOFF
    ldr x9, [x9]
    ldr x9, [x9]  // x9 = latest entry in dictionary
    str x9, [x13]

    // zero cfa
    mov x9, #0xEEEE
    str x9, [x13, #8]

    // store name length
    strb w14, [x13, #16]

    // copy name to the correct place
    dup_
    add x15, x13, #17  // x15 = address after link, cfa and name length
    str x15, [fp]
    bl move

    // align dictionary pointer
    dup_
    add x15, x15, x14 // x15 = address after entry
    mov x0, x15
    bl aligned
    adrp x9, _dp@PAGE
    add x9, x9, _dp@PAGEOFF
    str x0, [x9]

    // update latest definition
    mov x0, x13
    adrp x9, latestp@PAGE
    add x9, x9, latestp@PAGEOFF
    ldr x9, [x9]
    str x0, [x9]
    ldp x30, xzr, [sp], #16
    ret

anon:  // -> a
    stp x30, xzr, [sp, #-16]!
    bl startcomp
    bl here

    // compile: stp x30, xzr, [sp, #-16]!
    dup_
    mov x0, #0x7FFE
    movk x0, #0xA9BF, lsl #16
    ldp x30, xzr, [sp], #16
    b comma4

cexit:
    stp x30, xzr, [sp, #-16]!

    // compile: ldp x30, xzr, [sp], #16
    dup_
    mov x0, #0x7FFE
    movk x0, #0xA8C1, lsl #16
    bl comma4

    // compile: ret
    dup_
    mov x0, #0x03C0
    movk x0, #0xD65F, lsl #16

    ldp x30, xzr, [sp], #16
    b comma4

semicolon:
    stp x30, xzr, [sp, #-16]!
    bl cexit
    bl stopcomp
    ldp x30, xzr, [sp], #16
    ret

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
execmode:
    // search in forth then macro
    adrp x9, _search@PAGE
    add x9, x9, _search@PAGEOFF
    adrp x10, flatestp@PAGE
    add x10, x10, flatestp@PAGEOFF
    adrp x11, mlatestp@PAGE
    add x11, x11, mlatestp@PAGEOFF
    stp x10, x11, [x9]

    adrp x9, _action@PAGE
    add x9, x9, _action@PAGEOFF
    // execute if found in any of the dicts
    adrp x10, execute@PAGE
    add x10, x10, execute@PAGEOFF
    stp x10, x10, [x9]
    // do nothing for numbers and abort
    adrp x10, nil@PAGE
    add x10, x10, nil@PAGEOFF
    stp x10, x10, [x9, #16]
    ret

stopcomp:
    // Based on https://developer.apple.com/documentation/apple-silicon/porting-just-in-time-compilers-to-apple-silicon?preferredLanguage=occ
    stp x30, xzr, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    bl execmode
    dup_
    mov x0, #1
    bl _pthread_jit_write_protect_np
    adrp x0, _codestart@PAGE
    add x0, x0, _codestart@PAGEOFF
    ldr x0, [x0]
    mov x19, x0  // x19 = address
    mov x1, #(_codesize & 0xFFFF)
    mov x20, #(_codesize >> 16)
    add x1, x1, x20, lsl #16
    mov x20, x1  // x20 = length
    mov x2, #(PROT_READ | PROT_EXEC)
    bl _mprotect // TODO abort on error
    mov x0, x19
    mov x1, x20
    bl _sys_icache_invalidate
    drop_
    ldp x19, x20, [sp], #16
    ldp x30, xzr, [sp], #16
    ret

startcomp:
    stp x30, xzr, [sp, #-16]!
    // search in macro then forth
    adrp x9, _search@PAGE
    add x9, x9, _search@PAGEOFF
    adrp x10, mlatestp@PAGE
    add x10, x10, mlatestp@PAGEOFF
    adrp x11, flatestp@PAGE
    add x11, x11, flatestp@PAGEOFF
    stp x10, x11, [x9]

    adrp x9, _action@PAGE
    add x9, x9, _action@PAGEOFF
    adrp x10, execute@PAGE
    add x10, x10, execute@PAGEOFF     // execute if found in macro
    adrp x11, ccall@PAGE
    add x11, x11, ccall@PAGEOFF       // compile call if found in forth
    stp x10, x11, [x9]

    adrp x10, clit@PAGE
    add x10, x10, clit@PAGEOFF        // compile literal for numbers
    adrp x11, dictrewind@PAGE
    add x11, x11, dictrewind@PAGEOFF  // rewind dictionary for abort
    stp x10, x11, [x9, #16]

    // Based on https://developer.apple.com/documentation/apple-silicon/porting-just-in-time-compilers-to-apple-silicon?preferredLanguage=occ
    dup_
    adrp x0, _codestart@PAGE
    add x0, x0, _codestart@PAGEOFF
    ldr x0, [x0]
    mov x1, #(_codesize & 0xFFFF)
    mov x11, #(_codesize >> 16)
    add x1, x1, x11, lsl #16
    mov x2, #(PROT_READ | PROT_WRITE)
    bl _mprotect // TODO abort on error

    mov x0, #0
    bl _pthread_jit_write_protect_np
    drop_
    ldp x30, xzr, [sp], #16
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
    adrp x0, _h@PAGE
    add x0, x0, _h@PAGEOFF
    ret

here:  // -> a
    dup_
    adrp x0, _h@PAGE
    add x0, x0, _h@PAGEOFF
    ldr x0, [x0]
    ret

ccall:  // a ->
    stp x30, xzr, [sp, #-16]!
    stp x19, x20, [sp, #-16]!

    // calculate call offset
    bl here           // x0 = instruction address
    ldr x19, [fp]     // x19 = target address
    mov x20, x19      // x20 = target address
    sub x19, x19, x0  // x19 = offset to target

    // is offset greater than 128MB?
    mov x10, #0x0800
    lsl x10, x10, #16
    cmp x19, x10
    b.gt 1f

    // is offset smaller than -128MB?
    mov x11, #-1
    mul x10, x10, x11
    cmp x19, x10
    b.lt 1f

    // offset between [-128, 128] MB, compile: bl offset
    drop_
    mov x0, x19
    asr x0, x0, #2
    and x0, x0, #0x3FFFFFF
    mov x9, #0x94000000        // bl
    orr x0, x0, x9             // offset
    bl comma4
    b 3f

1:  mov x19, x20               // x19 = target address

    // compile 1st 16 bits
    movz x0, #0xD280, lsl #16  // movz
    and x20, x19, #0xFFFF      // imm16
    lsl x20, x20, #5           // ...
    add x20, x20, #9           // reg = x9
    orr x0, x0, x20
    bl comma4

    lsr x19, x19, #16          // did we exhaust the literal?
    cbz x19, 2f                // yes, we're done

    // compile 2nd 16 bits
    dup_
    movz x0, #0xF2A0, lsl #16  // movk
    and x20, x19, #0xFFFF      // imm16
    lsl x20, x20, #5           // ...
    add x20, x20, #9           // reg = x9
    orr x0, x0, x20
    bl comma4

    lsr x19, x19, #16          // did we exhaust the literal?
    cbz x19, 2f                // yes, we're done

    // compile 3nd 16 bits
    dup_
    movz x0, #0xF2C0, lsl #16  // movk
    and x20, x19, #0xFFFF      // imm16
    lsl x20, x20, #5           // ...
    add x20, x20, #9           // reg = x9
    orr x0, x0, x20
    bl comma4

    lsr x19, x19, #16          // did we exhaust the literal?
    cbz x19, 2f                // yes, we're done

    // compile 4th 16 bits
    dup_
    movz x0, #0xF2E0, lsl #16  // movk
    and x20, x19, #0xFFFF      // imm16
    lsl x20, x20, #5           // ...
    add x20, x20, #9           // reg = x9
    orr x0, x0, x20
    bl comma4

2:  movz x0, #0xD63F, lsl #16  // blr
    movz x19, #9               // reg = x9
    lsl x19, x19, #5
    add x0, x0, x19
    bl comma4

3:  ldp x19, x20, [sp], #16
    ldp x30, x21, [sp], #16
    ret


cdup:
    dup_
    mov x0, #0x8FA0
    movk x0, #0xF81F, lsl #16
    b comma4

cdrop:
    dup_
    mov x0, #0x87A0
    movk x0, #0xF840, lsl #16
    b comma4

clit:  // n ->
    stp x30, xzr, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    bl cdup
    mov x19, x0

    // compile 1st 16 bits
    movz x0, #0xD280, lsl #16  // movz
    and x20, x19, #0xFFFF      // imm16
    lsl x20, x20, #5           // ...
    orr x0, x0, x20
    bl comma4

    lsr x19, x19, #16          // did we exhaust the literal?
    cbz x19, 1f                // yes, we're done

    // compile 2nd 16 bits
    dup_
    movz x0, #0xF2A0, lsl #16  // movk
    and x20, x19, #0xFFFF      // imm16
    lsl x20, x20, #5           // ...
    orr x0, x0, x20
    bl comma4

    lsr x19, x19, #16          // did we exhaust the literal?
    cbz x19, 1f                // yes, we're done

    // compile 3nd 16 bits
    dup_
    movz x0, #0xF2C0, lsl #16  // movk
    and x20, x19, #0xFFFF      // imm16
    lsl x20, x20, #5           // ...
    orr x0, x0, x20
    bl comma4

    lsr x19, x19, #16          // did we exhaust the literal?
    cbz x19, 1f                // yes, we're done

    // compile 4th 16 bits
    dup_
    movz x0, #0xF2E0, lsl #16  // movk
    and x20, x19, #0xFFFF      // imm16
    lsl x20, x20, #5           // ...
    orr x0, x0, x20
    bl comma4

1:  ldp x19, x20, [sp], #16
    ldp x30, xzr, [sp], #16
    ret

    .data
_qmsg:  .ascii "?\n"
_qlen = . - _qmsg
    .text
    .p2align 2
abort:
    stp x30, xzr, [sp, #-16]!
    dup_
    adrp x0, _inbuf@PAGE
    add x0, x0, _inbuf@PAGEOFF
    ldr x0, [x0]
    dup_
    adrp x0, _inpos@PAGE
    add x0, x0, _inpos@PAGEOFF
    ldr x0, [x0]
    bl type
    dup_
    adrp x0, _qmsg@PAGE
    add x0, x0, _qmsg@PAGEOFF
    dup_
    mov x0, #_qlen
    bl type
    bl resetinput
    bl resetstacks
    ldp x30, xzr, [sp], #16
    b warm

    .data
    .p2align 2
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
    adrp x0, _search@PAGE
    add x0, x0, _search@PAGEOFF
    ldr x0, [x0]
    bl dfind
    cbz x0, 1f        // entry not found, continue
    add x0, x0, #8    // get CFA
    ldr x0, [x0]
    adrp x9, _action@PAGE
    add x9, x9, _action@PAGEOFF
    ldr x9, [x9]
    b 4f

1:  mov x0, x20
    dup_
    mov x0, x19
    dup_
    adrp x0, _search@PAGE
    add x0, x0, _search@PAGEOFF
    ldr x0, [x0, #8]
    bl dfind
    cbz x0, 2f        // entry not found, continue
    add x0, x0, #8    // get CFA
    ldr x0, [x0]
    adrp x9, _action@PAGE
    add x9, x9, _action@PAGEOFF
    ldr x9, [x9, #8]
    b 4f

2:  mov x0, x20
    dup_
    mov x0, x19
    bl number
    cbnz x0, 3f
    drop_
    adrp x9, _action@PAGE
    add x9, x9, _action@PAGEOFF
    ldr x9, [x9, #16]
    b 4f

3:  adrp x9, _action@PAGE
    add x9, x9, _action@PAGEOFF
    ldr x9, [x9, #24]
    blr x9
    adrp x9, abort@PAGE
    add x9, x9, abort@PAGEOFF

4:  ldp x19, x20, [sp], #16
    ldp x30, xzr, [sp], #16
    br x9

    .p2align 2
dictrewind:
    stp x30, xzr, [sp, #-16]!
    bl latest
    ldr x0, [x0]    // x0 = [mf]latest
    ldr x9, [x0]    // x9 = latest defined header in current dict
    ldr x9, [x9]    // x9 = next to latest defined header
    str x9, [x0]    // make next to latest the new latest
    drop_
    ldp x30, xzr, [sp], #16
    ret

    .p2align 2
execute:
    mov x9, x0
    drop_
    br x9

    .p2align 2
resetinput:
    mov x9, #0
    adrp x10, _inused@PAGE
    add x10, x10, _inused@PAGEOFF
    adrp x11, _inpos@PAGE
    add x11, x11, _inpos@PAGEOFF
    str x9, [x10]
    str x9, [x11]
    ret

    .p2align 2
setreadkern:
    adrp x9, _kernbuf@PAGE
    add x9, x9, _kernbuf@PAGEOFF
    adrp x10, _inbuf@PAGE
    add x10, x10, _inbuf@PAGEOFF
    str x9, [x10]

    mov x9, #_kerntot
    adrp x10, _intot@PAGE
    add x10, x10, _intot@PAGEOFF
    str x9, [x10]
    adrp x10, _inused@PAGE
    add x10, x10, _inused@PAGEOFF
    str x9, [x10]

    adrp x9, _inpos@PAGE
    add x9, x9, _inpos@PAGEOFF
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

    .global main, _main
    .text
    .p2align 2
_main:
main:
    bl resetstacks
    dup_
    mov x0, #0xdead
    dup_
    mov x0, #0xbeef

    bl resetdict
    bl execmode
    bl setreadkern
warm:
    bl readloop
    b bye

Br:
    brk #0xf000
    ret

    .p2align 2
resetstacks:
    adrp fp, dstack0+8@PAGE
    add fp, fp, dstack0+8@PAGEOFF
    ret

    .data
_dictstart: .quad 0
_dictsize = 0x100000
_codestart: .quad 0
_codesize = 0x100000

    .text
    .p2align 2
resetdict:
    stp x30, xzr, [sp, #-16]!

    // dictionary
    dup_
    mov x0, #_dictsize
    bl _malloc
    cmp x0, #0
    b.eq 1f
    adrp x9, _dp@PAGE
    add x9, x9, _dp@PAGEOFF
    adrp x10, _dictstart@PAGE
    add x10, x10, _dictstart@PAGEOFF
    str x0, [x9]
    str x0, [x10]

    // code space
    mov x0, #_codesize
    bl _malloc
    cmp x0, #0
    b.eq 1f
    adrp x9, _h@PAGE
    add x9, x9, _h@PAGEOFF
    adrp x10, _codestart@PAGE
    add x10, x10, _codestart@PAGEOFF
    str x0, [x9]
    str x0, [x10]
    drop_

    ldp x30, xzr, [sp], #16
    ret
1:  b _exit

_kernbuf:
.incbin "hello.ns"
_kerntot = . - _kernbuf

