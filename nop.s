.macro dup_
    lea -8(%rbp), %rbp
    mov %rax, (%rbp)
.endm

.macro drop_
    mov (%rbp), %rax
    lea 8(%rbp), %rbp
.endm

.include "sysdefs.inc"

    .text
sysread:
    mov $SYSREAD, %rcx
    jmp _sysrw

syswrite:
    mov $SYSWRITE, %rcx
_sysrw:
    push %rdx
    mov %rax, %rdi
    drop_
    mov %rax, %rdx
    drop_
    mov %rax, %rsi
    mov %rcx, %rax
    syscall
    pop %rdx
    ret

sysexit:
    mov %rax, %rdi
    movq $SYSEXIT, %rax
    syscall

sysopen:
    mov %rax, %rsi
    drop_
    mov %rax, %rdi
    mov $SYSOPEN, %rax
    syscall
    ret

sysclose:
    mov %rax, %rdi
    mov $SYSCLOSE, %rax
    syscall
    ret

sysmmap:
    push %rdx
    mov $0, %rdi         # addr
    mov %rax, %r10
    drop_
    mov %rax, %rdx
    drop_
    mov %rax, %rsi
    mov $-1, %r8         # fd
    mov $0, %r9          # offset (ignored)
    mov $SYSMMAP, %rax
    syscall
    pop %rdx
    ret

expect:
    dup_
    xor %rax, %rax  # stdin
    call sysread
    ret

type:
    dup_
    mov $1, %rax    # stdout
    call syswrite
    drop_
    ret

    .data
_buf1: .byte 0
    .text

emit:
    movb %al, _buf1(%rip)
    lea _buf1(%rip), %rax
    dup_
    mov $1, %rax
    call type
    ret

key:
    dup_
    lea _buf1(%rip), %rax
    dup_
    mov $1, %rax
    call expect
    test %rax, %rax  # EOF
    jz 1f
    movzbq _buf1(%rip), %rax
    ret
1:  movb $-1, %al
    ret

skip:
    mov %rax, %rcx
    drop_
    mov %rax, %rdi
    drop_
    repe scasb
    jz 1f
    dec %rdi
    inc %rcx
1:  mov %rdi, %rax
    dup_
    mov %rcx, %rax
    ret

scan:
    mov %rax, %rcx
    drop_
    mov %rax, %rdi
    drop_
    repne scasb
    jnz 1f            # if we found a delimiter,
    dec %rdi          # %rdi is after it, so we revert
    inc %rcx
1:  mov %rdi, %rax
    dup_
    mov %rcx, %rax
    ret

# translated from cmforth
digit:
    sub $48, %rax         # convert ascii digit to binary
    cmp $9, %rax          # is it < 9?
    jle 2f                # yes, go out
    sub $7, %rax          # no, number in a base > 10
    dup_
    cmp $10, %rax         # is it < 10?
    mov $0, %rax          # no, T = 0
    jnl 1f                # yes,
    sub $1, %rax          # T = -1
1:
    or (%rbp), %rax
    lea 8(%rbp), %rbp     # discard S
2:
    cmpb _base(%rip), %al
    jl 3f
    mov $-1, %rax
3:
    ret

number:
    mov %rax, %rcx
    drop_

    movzbq (%rax), %rsi
    xor $'-', %rsi
    push %rsi
    cmp $0, %rsi
    jne 1f
    inc %rax
    dec %rcx
1:
    mov %rax, %rsi

    # accumulate in rbx
    xor %rbx, %rbx
    movzbq _base(%rip), %rdx
2:
    imul %rdx, %rbx
    movzbq (%rsi), %rax
    call digit
    cmp $-1, %rax
    jle 4f
    add %rax, %rbx
    inc %rsi
    loop 2b

    mov %rbx, %rax
    pop %rsi
    cmp $0, %rsi
    jne 3f
    neg %rax
3:
    dup_
    mov $0, %rax
    ret
4:
    pop %rsi
    mov %rcx, %rax
    dup_
    ret

    .data
_inbuf: .space 256, 0    # input buffer
_inbuftot: .short 256    # input buffer total size
_inbuflen: .short 0      # input buffer used size
_inpos: .short 0         # current input pointer
_base: .byte 10          # numeric base

    .text
inbuf:
    dup_
    lea _inbuf(%rip), %rax
    movzwq _inpos(%rip), %rcx
    lea (%rcx, %rax), %rax
    dup_
    movzwq _inbuflen(%rip), %rax
    sub %rcx, %rax                 # rax = positions consumed
    jns 1f
    xor %rax, %rax
1:  ret

word:
    dup_
    call inbuf
    push %rax
    call skip
    pop %rcx
    sub %rax, %rcx          # rcx = consumed bytes
    add %rcx, _inpos(%rip)

    # stack is: c a' n'
    push (%rbp)
    push %rax
    call scan
    pop %rcx
    sub %rax, %rcx          # rcx = consumed bytes
    add %rcx, _inpos(%rip)

    test %rax, %rax         # c was not found
    jz 1f
    add $1, _inpos(%rip)    # consume c

1:  pop %rsi
    push %rcx
    mov _h(%rip), %rdi
    mov %rdi, (%rbp)
    rep movsb
    pop %rax
    ret

    .data
_h: .quad 0              # next dictionary address
_latest: .quad _flatest

    .text
flatest:
    dup_
    mov _flatest(%rip), %rax
    ret

mlatest:
    dup_
    mov _mlatest(%rip), %rax
    ret

latest:
    dup_
    mov _latest(%rip), %rax
    mov (%rax), %rax
    ret

macro:
    lea _mlatest(%rip), %rcx
    jmp 1f
forth:
    lea _flatest(%rip), %rcx
1:
    mov %rcx, _latest(%rip)
    ret

comma:
    mov _h(%rip), %rdx
    mov %rax, (%rdx)
    add $8, %rdx
    mov %rdx, _h(%rip)
    drop_
    ret

comma4:
    mov _h(%rip), %rdx
    mov %eax, (%rdx)
    add $4, %rdx
    mov %rdx, _h(%rip)
    drop_
    ret

comma1:
    mov _h(%rip), %rdx
    movb %al, (%rdx)
    inc %rdx
    mov %rdx, _h(%rip)
    drop_
    ret

comma2:
    mov _h(%rip), %rdx
    movw %ax, (%rdx)
    add $2, %rdx
    mov %rdx, _h(%rip)
    drop_
    ret

dovar:
    dup_
    pop %rax
    ret

aligned:
    add $7, %rax
    and $~7, %rax
    ret

centry:
    # copy name to the correct place
    mov (%rbp), %rsi
    mov _h(%rip), %rdi
    add $17, %rdi        # link + cfa + name length
    mov %rax, %rcx
    cld
    rep; movsb

    mov _h(%rip), %rcx
    push %rcx
    call latest
    call comma

    # make room for cfa
    mov _h(%rip), %rcx
    add $8, %rcx
    mov %rcx, _h(%rip)

    dup_
    call comma1            # store name length
    mov _h(%rip), %rcx
    add %rax, %rcx
    mov %rcx, _h(%rip)     # commit name
    drop_

    mov _h(%rip), %rax
    call aligned
    mov %rax, _h(%rip)

    pop %rax
    mov _latest(%rip), %rcx
    mov %rax, (%rcx)

    # fix cfa
    call tocfa
    mov _h(%rip), %rcx
    mov %rcx, (%rax)
    drop_
    ret

entry:
    dup_
    mov $' ', %rax
    call word
    call centry
    ret

create:
    call entry
    dup_
    lea dovar(%rip), %rax
    call ccall
    ret

colon:
    call entry
    call anon
    drop_
    ret

anon:
    dup_
    mov _h(%rip), %rax
    call startcomp
    ret

cexit:
    call here
    sub $2, %rax
    movw (%rax), %cx
    cmp $0xD1FF, %cx      # is it a call?
    jne 1f
    movw $0xE1FF, (%rax)  # convert to a jump
    drop_
    ret
1:  mov $0xC3, %rax       # or compile a ret
    call comma1
    ret

semicolon:
    call cexit
    call stopcomp
    ret

stopcomp:
    movb $0, _compiling(%rip)
    ret

startcomp:
    movb $1, _compiling(%rip)
    ret

dfind:
    cld
    push %rax
    drop_
    mov %rax, %rcx        # string count
    drop_
    mov %rax, %rsi        # string length
    pop %rax              # list address
1:
    test %rax, %rax       # end of list?
    jnz 2f
    ret
2:
    movzbq 16(%rax), %rdx  # name length
    cmp %rcx, %rdx
    jne 3f
    push %rsi
    push %rcx
    lea 17(%rax), %rdi     # pointer to name
    repe cmpsb
    pop %rcx
    pop %rsi
    jnz 3f
    ret
3:
    mov (%rax), %rax
    jmp 1b

tocfa:
    lea 8(%rax), %rax
    ret

h:
    dup_
    lea _h(%rip), %rax
    ret

here:
    dup_
    mov _h(%rip), %rax
    ret

ccall:
    dup_
    # compile move immediate to rcx
    mov $0xB948, %rax
    call comma2
    call comma
    # compile absolute call to rcx
    dup_
    mov $0xD1FF, %rax
    call comma2
    ret

cdup:
    dup_
    mov $0x00458948F86D8D48, %rax
    call comma
    ret

cdrop:
    dup_
    mov $0x086D8D4800458B48, %rax
    call comma
    ret

cswap:
    dup_
    mov $0x458748, %rax    # xchg %rax, (%rbp)
    call comma4
    ret

cover:
    call cdup
    dup_
    mov $0x08458b48, %rax   # mov 8(%rbp), %rax
    call comma4
    ret

cpop:
    call cdup
    dup_
    mov $0x58, %rax
    call comma1
    ret

cpush:
    dup_
    mov $0x50, %rax
    call comma1
    call cdrop
    ret

cfetch:
    # mov (%rax), %rax
    dup_
    mov $0x8b48, %rax
    call comma2
    dup_
    xor %rax, %rax
    call comma1
    ret

cbfetch:
    dup_
    mov $0x00b60f48, %rax    # movzbq (%rax), %rax
    call comma4
    ret

cstore:
    dup_
    mov $0x004d8b48, %rax    # mov (%rbp), %rcx
    call comma4
    # mov %rcx, (%rax)
    dup_
    mov $0x8948, %rax
    call comma2
    dup_
    mov $0x08, %rax
    call comma1
    call cdrop
    call cdrop
    ret

cbstore:
    dup_
    mov $0x004d8b48, %rax    # mov (%rbp), %rcx
    call comma4
    dup_
    mov $0x0888, %rax        # mov %cl, (%rax)
    call comma2
    call cdrop
    call cdrop
    ret

cadd:
    dup_
    mov $0x00450148, %rax    # add %rax, (%rbp)
    call comma4
    call cdrop
    ret

csub:
    dup_
    mov $0x00452948, %rax    # add %rax, (%rbp)
    call comma4
    call cdrop
    ret

cmul:
    # imul (%rbp),%rax
    # lea 0x8(%rbp),%rbp
    dup_
    mov $0x48, %rax
    call comma1
    dup_
    mov $0x086d8d480045af0f, %rax
    call comma
    ret

cdivmod:
    call cswap
    dup_
    mov $0x9948, %rax    # cqto
    call comma2
    dup_
    # idivq (%rbp)
    # xchg %rdx, (%rbp)
    mov $0x00558748007df748, %rax
    call comma
    ret

cne:
    dup_
    mov $0x95, %rax
    jmp ccmp

cle:
    dup_
    mov $0x9e, %rax
    jmp ccmp

cge:
    dup_
    mov $0x9d, %rax
    jmp ccmp

clt:
    dup_
    mov $0x9c, %rax
    jmp ccmp

cgt:
    dup_
    mov $0x9f, %rax
    jmp ccmp

ceq:
    dup_
    mov $0x94, %rax

ccmp:
    dup_
    mov $0x00453948, %rax          # cmp %rax, (%rbp)
    call comma4
    dup_
    mov $0x0f, %rax                # setX %al
    call comma1
    or $0xc000, %rax               # ...
    call comma2
    dup_
    mov $0x086d8d48c0b60f48, %rax  # movzbq %al, %rax; lea 8(%rbp), %rbp
    call comma
    ret


cif:
    dup_
    mov $0x8548, %rax    # test %rax, %rax
    call comma2
    dup_
    mov $0xC0, %rax      # ...
    call comma1
    call cdrop
    dup_
    mov $0x0074, %rax    # jz 0
    call comma2
    call here
    dec %rax
    ret

cjump:
    dup_
    mov $0xEB, %rax    # jmp
    call comma1
    call comma1
    ret

clit:
    call cdup
    dup_
    mov $0xb848, %rax
    call comma2
    call comma
    ret

    .data
.global _compiling
_compiling: .byte 0

    .text
_errmsg: .ascii " ?\n"
_errmsglen = . - _errmsg

    .text
errmsg:
    dup_
    lea _inbuf(%rip), %rax
    dup_
    movzwq _inpos(%rip), %rax
    call type
    dup_
    lea _errmsg(%rip), %rax
    dup_
    mov $_errmsglen, %rax
    call type
    ret

abort:
    call errmsg
    call resetinput
    call resetstacks
    jmp readloop

eval:
    # save string
    push %rax
    push (%rbp)

    call flatest
    call dfind
    test %rax, %rax
    jnz 2f
    mov (%rsp), %rax
    dup_
    mov 8(%rsp), %rax
    call mlatest
    call dfind
    test %rax, %rax
    jz 3f
2:
    pop %rcx
    pop %rcx
    call tocfa
    mov (%rax), %rax
    call execute
    ret

3:
    mov (%rsp), %rax
    dup_
    mov 8(%rsp), %rax
    call number
    test %rax, %rax
    jnz 4f
    drop_
    pop %rcx
    pop %rcx
    ret
4:
    pop %rcx
    pop %rcx
    jmp abort

compile:
    # save string
    push %rax
    push (%rbp)

    call mlatest
    call dfind
    test %rax, %rax
    jz 2f
    pop %rcx
    pop %rcx
    call tocfa
    mov (%rax), %rax
    call execute
    ret

2:
    mov (%rsp), %rax
    dup_
    mov 8(%rsp), %rax
    call flatest
    call dfind
    test %rax, %rax
    jz 3f
    pop %rcx
    pop %rcx
    call tocfa
    mov (%rax), %rax
    call ccall
    ret
3:
    mov (%rsp), %rax
    dup_
    mov 8(%rsp), %rax
    call number
    test %rax, %rax
    jnz 4f
    drop_
    pop %rcx
    pop %rcx
    call clit
    ret
4:
    pop %rcx
    pop %rcx
    call dictrewind
    jmp abort

dictrewind:
    call latest                # rax = pointer to latest entry
    mov (%rax), %rax           # rax = pointer to next to latest entry
    mov _latest(%rip), %rcx
    mov %rax, (%rcx)
    drop_
    ret


execute:
    mov %rax, %rbx
    drop_
    jmp *%rbx

resetinput:
    xor %rcx, %rcx
    movw %cx, _inbuflen(%rip)
    movw %cx, _inpos(%rip)
    ret

qrefill:
    movzwq _inpos(%rip), %rcx
    movzwq _inbuflen(%rip), %rdx
    cmp %rcx, %rdx
    je refill
    dup_
    mov $1, %rax
    ret

refill:
    call resetinput

1:  # if we filled the whole input, exit
    movzwq _inbuflen(%rip), %rcx
    movzwq _inbuftot(%rip), %rdx
    cmp %rcx, %rdx
    jne 2f
    dup_
    mov $1, %rax
    ret

2:  call key
    cmpb $-1, %al   # EOF
    jne 3f
    mov $0, %rax
    movzwq _inbuflen(%rip), %rcx
    or %rcx, %rax
    ret

3:  cmpb $10, %al
    jne 4f
    mov $1, %rax
    ret

4:  mov %rax, %rdx
    lea _inbuf(%rip), %rax
    movzwq _inbuflen(%rip), %rcx
    lea (%rcx, %rax), %rax          # rax = pointer to next byte to be used
    mov %dl, (%rax)
    drop_
    inc %rcx
    movw %cx, _inbuflen(%rip)
    jmp 1b

readloop:
    call qrefill
    cmp $0, %rax
    jz bye

    mov $' ', %rax
    call word
    test %rax, %rax
    jnz 1f
    drop_
    drop_
    jmp readloop

1:  movb _compiling(%rip), %cl
    test %cl, %cl
    jnz 2f
    call eval
    jmp 3f
2:  call compile
3:  call checkstacks
    jmp readloop


    .data
_banner:     .ascii "nop forth\n"
_blen =      . - _banner

    .text
banner:
    dup_
    lea _banner(%rip), %rax
    dup_
    mov $_blen, %rax
    call type
    ret

bye:
    xor %rax, %rax
    call sysexit

    .data
dstack: .space 8192, 0
dstack0:
_R0: .quad 0             # return stack base
_S0: .quad 0             # parameter stack base
_Send: .quad 0           # parameter stack end

    .text

    .global boot
boot:
    mov %rsp, _R0(%rip)
    call resetstacks
    call resetdict
    call banner

    jmp readloop

resetstacks:
    lea dstack0(%rip), %rbp
    mov %rbp, _S0(%rip)
    lea dstack(%rip), %rax
    mov %rax, _Send(%rip)

    # markers for debugging
    mov $0xFEED, %rax
    dup_
    mov $0xBEEF, %rax

    pop %rbx
    mov _R0(%rip), %rsp
    push %rbx
    ret

    .data
_undererr: .ascii "stack underflow!\n"
_undererrlen = . - _undererr
_overerr:  .ascii "stack overflow!\n"
_overerrlen = . - _overerr

    .text
checkstacks:
    cmp _S0(%rip), %rbp
    jg 1f
    cmp _Send(%rip), %rbp
    jl 2f
    ret
1:
    dup_
    lea _undererr(%rip), %rax
    dup_
    mov $_undererrlen, %rax
    jmp 3f
2:
    dup_
    lea _overerr(%rip), %rax
    dup_
    mov $_overerrlen, %rax
3:
    call type
    jmp abort
    
resetdict:
    dup_
    mov $0x2000, %rax
    dup_
    mov $(PROT_READ | PROT_WRITE | PROT_EXEC), %rax
    dup_
    mov $(MAP_ANONYMOUS | MAP_SHARED), %rax
    call sysmmap
    jz 1f
    mov %rax, _h(%rip)
    drop_
    ret
1:
    mov $1, %rax
    call sysexit

B:
    int3
    ret

.include "dicts.s"
