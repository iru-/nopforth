.macro dup_
    lea -8(%rbp), %rbp
    mov %rax, (%rbp)
.endm

.macro drop_
    mov (%rbp), %rax
    lea 8(%rbp), %rbp
.endm

.include "x86-64/sysdefs.inc"

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
    mov %rax, %rsi
    drop_
    mov %rax, %rdi
    call dlopen@plt
    ret

_dlsym:
    mov %rax, %rsi
    drop_
    mov %rax, %rdi
    call dlsym@plt
    ret

_dlclose:
    mov %rax, %rdi
    call dlclose@plt
    ret

_dlerror:
    call dlerror@plt
    ret

expect:
    dup_
    mov _infd(%rip), %rax
    jmp sysread

type:
    dup_
    mov $1, %rax    # stdout
    call syswrite
    drop_
    ret

    .data
_keyxt: .quad 0
    .text
keyxt:
    dup_
    lea _keyxt(%rip), %rax
    ret

key:
    jmp *_keyxt(%rip)

skip:
    cmp $0, (%rbp)     # empty string
    jnz 1f
    drop_
    ret
1:  mov %rax, %rdx
    drop_
    mov %rax, %rcx
    drop_
    mov %rax, %rdi
    mov %rdx, %rax
    repe scasb
    jz 2f              # if we didn't find a delimiter,
    dec %rdi           # %rdi is after the first non-delimiter, so we revert
    inc %rcx
2:  mov %rdi, %rax
    dup_
    mov %rcx, %rax
    ret

skipws:
    mov (%rbp), %rdx
1:  test %rax, %rax
    jz 2f
    movzbq (%rdx), %rbx
    cmp $0x20, %bl       # ascii space
    jg 2f
    inc %rdx
    dec %rax
    jmp 1b

scanws:
    mov (%rbp), %rdx
1:  test %rax, %rax
    jz 2f
    movzbq (%rdx), %rbx
    cmp $0x20, %bl       # ascii space
    jle 2f
    inc %rdx
    dec %rax
    jmp 1b
2:  mov %rdx, (%rbp)
3:  ret

scan:
    cmp $0, (%rbp)     # empty string
    jnz 1f
    drop_
    ret
1:  mov %rax, %rdx
    drop_
    mov %rax, %rcx
    drop_
    mov %rax, %rdi
    mov %rdx, %rax
    repne scasb
    jnz 2f             # if we found a delimiter,
    dec %rdi           # %rdi is after it, so we revert
    inc %rcx
2:  mov %rdi, %rax
    dup_
    mov %rcx, %rax
    ret

toupper:
    cmp $'a', %rax
    jl 2f             # not lower case
    cmp $'z', %rax
    jg 2f             # not lower case
    xor $32, %rax
2:  ret

# translated from cmforth
digit:
    mov %rax, %rdx        # rdx = base
    drop_                 # rax = ascii digit
    call toupper          # normalize to upper case
    sub $'0', %rax        # convert to binary
    cmp $9, %rax          # is it <= 9?
    jle 2f                # yes, go out
                          # no, number is in a base > 10
    sub $7, %rax          # subtract the digits between '9' and 'A'
    cmp $10, %rax         # is it < 10?
    mov $0, %rcx          # no, rcx = 0
    jnl 1f                # yes,
    mov $-1, %rcx         # rcx = -1
1:  or %rcx, %rax
2:  cmp $0, %rax
    jl 3f
    cmp %rdx, %rax        # is the number less than base?
    jl 4f                 # yes, we're done
3:  mov $-1, %rax         # no, it is an error
4:  ret

number:
    mov %rax, %rcx        # rcx = length
    drop_                 # rax = string

    cmp $0, %rcx          # zero length string?
    je 4f

    movzbq (%rax), %rsi
    cmp $'-', %rsi        # is the number negative?
    jne 0f                # no, jump
    push $1               # yes, push 1
    inc %rax              # advance to next byte
    dec %rcx
    jmp 1f

0:  push $0               # positive number
1:  movzbq (%rax), %rsi
    cmp $'$', %rsi        # is the number in hex?
    jne 2f
    mov $16, %rdx         # rdx = base 16
    inc %rax              # advance to next byte
    dec %rcx
    jmp 3f

2:  mov $10, %rdx         # rdx = base 10
3:  mov %rax, %rsi

    # accumulate in rbx
    xor %rbx, %rbx

3:  imul %rdx, %rbx
    movzbq (%rsi), %rax
    push %rcx
    push %rdx
    dup_
    mov %rdx, %rax
    call digit
    pop %rdx
    pop %rcx
    cmp $0, %rax
    jl 5f
    add %rax, %rbx
    inc %rsi
    loop 3b

    mov %rbx, %rax
    pop %rsi
    cmp $1, %rsi
    jne 4f
    neg %rax

4:  dup_
    mov $0, %rax          # no bytes left to process
    ret

5:  pop %rsi
    dup_
    mov %rcx, %rax        # failed to convert, rcx bytes left
    ret

    .data
_infd:   .quad 0    # file descriptor feeding the input
_inbuf:  .quad 0    # pointer to input buffer
_intot:  .quad 0    # input buffer total size
_inused: .quad 0    # input buffer used size
_inpos:  .quad 0    # input buffer position

_base: .quad 10      # numeric base

    .text
base:
    dup_
    lea _base(%rip), %rax
    ret

infd:
    dup_
    lea _infd(%rip), %rax
    ret

inbuf:
    dup_
    lea _inbuf(%rip), %rax
    ret

intot:
    dup_
    lea _intot(%rip), %rax
    ret

inused:
    dup_
    lea _inused(%rip), %rax
    ret

inpos:
    dup_
    lea _inpos(%rip), %rax
    ret

source:
    dup_
    mov _inbuf(%rip), %rax
    mov _inpos(%rip), %rcx
    lea (%rcx, %rax), %rax
    dup_
    mov _inused(%rip), %rax
    sub %rcx, %rax                 # rax = positions consumed
    jns 1f
    xor %rax, %rax
1:  ret

nextword:
    call source
    test %rax, %rax
    jnz 1f
    ret
1:  push %rax
    call skipws
    pop %rcx
    sub %rax, %rcx          # rcx = consumed bytes
    add %rcx, _inpos(%rip)

    # save start and count of string
    push (%rbp)
    push %rax
    call scanws
    pop %rcx
    sub %rax, %rcx          # rcx = consumed bytes
    add %rcx, _inpos(%rip)

    test %rax, %rax         # c was not found
    jz 2f
    add $1, _inpos(%rip)    # consume c

2:  pop (%rbp)
    mov %rcx, %rax
    ret

word:
    push %rax               # save delimiter
    drop_
    call source
    test %rax, %rax
    jnz 1f
    pop %rcx
    ret
1:  push %rax
    dup_
    mov 8(%rsp), %rax       # retrieve delimiter
    call skip
    pop %rcx
    sub %rax, %rcx          # rcx = consumed bytes
    add %rcx, _inpos(%rip)

    pop %rcx                # retrieve delimiter
    # save start and count of string
    push (%rbp)
    push %rax
    dup_
    mov %rcx, %rax
    call scan
    pop %rcx
    sub %rax, %rcx          # rcx = consumed bytes
    add %rcx, _inpos(%rip)

    test %rax, %rax         # c was not found
    jz 2f
    add $1, _inpos(%rip)    # consume c

2:  pop (%rbp)
    mov %rcx, %rax
    ret

    .data
_h:    .quad 0   # next dictionary address
_latest: .quad _flatest

_hole: .quad _hole    # address of last optimizable instruction

    .text
hole:
    dup_
    lea _hole(%rip), %rax
    ret

flatest:
    dup_
    lea _flatest(%rip), %rax
    ret

mlatest:
    dup_
    lea _mlatest(%rip), %rax
    ret

latest:
    dup_
    lea _latest(%rip), %rax
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
    add $8, _h(%rip)
    drop_
    ret

comma4:
    mov _h(%rip), %rdx
    mov %eax, (%rdx)
    add $4, _h(%rip)
    drop_
    ret

comma1:
    mov _h(%rip), %rdx
    movb %al, (%rdx)
    incq _h(%rip)
    drop_
    ret

comma2:
    mov _h(%rip), %rdx
    movw %ax, (%rdx)
    add $2, _h(%rip)
    drop_
    ret

# XXX off-by-one
comma3:
    call comma4
    decq _h(%rip)
    ret

aligned:
    add $7, %rax
    and $~7, %rax
    ret

entry:
    call nextword

centry:
    mov _h(%rip), %rcx
    push %rcx

    # copy name to the correct place
    mov (%rbp), %rsi
    mov _h(%rip), %rdi
    lea 17(%rdi), %rdi    # link + cfa + name length
    mov %rax, %rcx
    cld
    rep; movsb

    # stack here is: nameptr length

    # store link
    dup_
    mov _latest(%rip), %rax
    mov (%rax), %rax
    call comma

    # store empty cfa
    dup_
    xor %rax, %rax
    call comma

    # store name
    dup_
    call comma1
    mov _h(%rip), %rcx
    add %rax, %rcx
    mov %rcx, _h(%rip)
    drop_

    # align dictionary pointer
    mov _h(%rip), %rax
    call aligned
    mov %rax, _h(%rip)

    # update latest definition
    pop %rax
    mov _latest(%rip), %rcx
    mov %rax, (%rcx)
    ret

colon:
    call entry
    call anon
    mov %rax, %rbx    # rbx <- code address
    drop_             # rax <- entry address
    call tocfa        # rax <- cfa
    mov %rbx, (%rax)
    drop_
    ret

anon:
    dup_
    mov _h(%rip), %rax
    jmp startcomp

cexit:
    call here
    sub $5, %rax
    cmp %rax, _hole(%rip)
    jne 1f
    mov (%rax), %cl
    cmp $0xE8, %cl      # is it a call?
    jne 1f
    movb $0xE9, (%rax)  # convert to a jump
    drop_
    ret
1:  mov $0xC3, %rax     # or compile a ret
    jmp comma1

semicolon:
    call cexit
    jmp stopcomp

stopcomp:
    lea _flatest(%rip), %rcx
    mov %rcx, _search(%rip)
    lea _mlatest(%rip), %rcx
    mov %rcx, _search+8(%rip)
    lea execute(%rip), %rcx
    mov %rcx, _action(%rip)
    mov %rcx, _action+8(%rip)
    lea nil(%rip), %rcx
    mov %rcx, _action+16(%rip)
    mov %rcx, _action+24(%rip)
    ret

startcomp:
    lea _mlatest(%rip), %rcx
    mov %rcx, _search(%rip)
    lea _flatest(%rip), %rcx
    mov %rcx, _search+8(%rip)
    lea execute(%rip), %rcx
    mov %rcx, _action(%rip)
    lea ccall(%rip), %rcx
    mov %rcx, _action+8(%rip)
    lea clit(%rip), %rcx
    mov %rcx, _action+16(%rip)
    lea dictrewind(%rip), %rcx
    mov %rcx, _action+24(%rip)
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
    mov _h(%rip), %rdx
    mov %rdx, _hole(%rip)

    # calculate call offset
    dup_
    call here
    add $5, %rax
    sub %rax, (%rbp)
    # data stack: call-destination offset where-to-compile-offset

    # check if offset fits in 32 bits
    # for us to compile a direct call
    mov (%rbp), %rsi
    cmpq $2147483647, %rsi
    jg 1f
    cmpq $-2147483648, %rsi
    jl 1f

    # offset fits
    mov $0xE8, %rax
    call comma1
    call comma4
    drop_
    ret

    # offset too big
1:  drop_
    mov $0xB948, %rax   # movabs $dest, %rcx
    call comma2
    call comma
    dup_
    mov $0xD1FF, %rax   # call *%rcx
    jmp comma2

cdup:
    dup_
    mov $0x00458948F86D8D48, %rax
    jmp comma

cdrop:
    dup_
    mov $0x086D8D4800458B48, %rax
    jmp comma

cswap:
    dup_
    mov $0x00458948005D8B48, %rax     # mov (%rbp), %rbx; mov %rax, (%rbp)
    call comma
    dup_
    mov $0xD88948, %rax               # mov %rbx, %rax
    jmp comma3

cnip:
    dup_
    mov $0x086D8D48, %rax    # lea 8(%rbp), %rbp
    jmp comma4

cover:
    call cdup
    dup_
    mov $0x08458B48, %rax   # mov 8(%rbp), %rax
    jmp comma4

cpop:
    call cdup
    dup_
    mov $0x58, %rax
    jmp comma1

cpush:
    dup_
    mov $0x50, %rax
    call comma1
    jmp cdrop

ca:
    call cdup
    dup_
    mov $0xE8894C, %rax    # mov %r13, %rax
    jmp comma3

castore:
    dup_
    mov $0xC58949, %rax    # mov %rax, %r13
    call comma3
    jmp cdrop

cfetch:
    dup_
    mov $0x008B48, %rax    # mov (%rax), %rax
    jmp comma3

cfetchplus:
    call cdup
    dup_
    mov $0x00458B49, %rax    # mov (%r13), %rax
    call comma4
    dup_
    mov $0x086D8D4D, %rax    # lea 8(%r13), %r13
    jmp comma4

cbfetch:
    dup_
    mov $0x00B60F48, %rax    # movzbq (%rax), %rax
    jmp comma4

cbfetchplus:
    call cdup
    # movzbq (%r13), %rax
    dup_
    mov $0x49, %rax
    call comma1
    dup_
    mov $0x0045B60F, %rax
    call comma4
    dup_
    mov $0x016D8D4D, %rax    # lea 1(%r13), %r13
    jmp comma4

cstore:
    dup_
    mov $0x004D8B48, %rax    # mov (%rbp), %rcx
    call comma4
    dup_
    mov $0x088948, %rax      # mov %rcx, (%rax)
    call comma3
    call cdrop
    jmp cdrop

cstoreplus:
    dup_
    mov $0x00458949, %rax    # mov %rax, (%r13)
    call comma4
    dup_
    mov $0x086D8D4D, %rax    # lea 8(%r13), %r13
    call comma4
    jmp cdrop

cbstore:
    dup_
    mov $0x004D8B48, %rax    # mov (%rbp), %rcx
    call comma4
    dup_
    mov $0x0888, %rax        # mov %cl, (%rax)
    call comma2
    call cdrop
    jmp cdrop

cbstoreplus:
    dup_
    mov $0x00458841, %rax    # mov %al, (%r13)
    call comma4
    dup_
    mov $0x016D8D4D, %rax    # lea 1(%r13), %r13
    call comma4
    jmp cdrop

cadd:
    dup_
    mov $0x00450148, %rax    # add %rax, (%rbp)
    call comma4
    jmp cdrop

csub:
    dup_
    mov $0x00452948, %rax    # sub %rax, (%rbp)
    call comma4
    jmp cdrop

cmul:
    # imul (%rbp),%rax
    # lea 0x8(%rbp),%rbp
    dup_
    mov $0x48, %rax
    call comma1
    dup_
    mov $0x086D8D480045AF0F, %rax
    jmp comma

cdivmod:
    call cswap
    dup_
    mov $0x9948, %rax    # cqto
    call comma2
    dup_
    # idivq (%rbp)
    # xchg %rdx, (%rbp)
    mov $0x00558748007DF748, %rax
    jmp comma

cor:
   dup_
   mov $0x00450B48, %rax    # or (%rbp), %rax
   call comma4
   jmp cnip

cand:
    dup_
    mov $0x00452348, %rax    # and (%rbp), %rax
    call comma4
    jmp cnip

cxor:
    dup_
    mov $0x00453348, %rax    # xor (%rbp), %rax
    call comma4
    jmp cnip

clnot:
    dup_
    mov $0xD0F748, %rax    # not %rax
    jmp comma3

cne:
    dup_
    mov $0x9500, %rax
    jmp ccmp

cle:
    dup_
    mov $0x9E00, %rax
    jmp ccmp

cge:
    dup_
    mov $0x9D00, %rax
    jmp ccmp

clt:
    dup_
    mov $0x9C00, %rax
    jmp ccmp

cgt:
    dup_
    mov $0x9F00, %rax
    jmp ccmp

ceq:
    dup_
    mov $0x9400, %rax

ccmp:
    dup_
    mov $0x00453948, %rax          # cmp %rax, (%rbp)
    call comma4
    or $0xC0000F, %rax             # setX %al
    call comma3
    dup_
    mov $0x086D8D48C0B60F48, %rax  # movzbq %al, %rax; lea 8(%rbp), %rbp
    call comma
    dup_
    mov $0xD8F748, %rax            # neg %rax
    jmp comma3

clit:
    call cdup
    dup_
    mov $0xB848, %rax
    call comma2
    jmp comma

    .data
_abortxt:  .quad abort1
_qmsg:     .ascii "?\n"
_qlen =    . - _qmsg

    .text
abortxt:
    dup_
    lea _abortxt(%rip), %rax
    ret

abort1:
    # Discard the argument passed in. It is there only to make this abort
    # consistent with the portable one
    mov _inbuf(%rip), %rax
    dup_
    mov _inpos(%rip), %rax
    call type
    dup_
    lea _qmsg(%rip), %rax
    dup_
    mov $_qlen, %rax
    call type
    call resetinput
    call resetstacks
    jmp warm

abort:
    jmp *_abortxt(%rip)

    .data
_search:
  .quad 0          # 1st dictionary to be searched
  .quad 0          # 2nd dictionary to be searched
_action:
  .quad 0          # action on 1st search found
  .quad 0          # action on 2nd search found
  .quad nil        # action on number found
  .quad nil        # abort action

    .text
nil: ret

eval:
    # save string
    push %rax
    push (%rbp)

    dup_
    mov _search(%rip), %rax
    call dfind
    test %rax, %rax
    jz 1f
    mov 8(%rax), %rax    # get CFA

    # discard saved string
    pop %rcx
    pop %rcx
    jmp *_action(%rip)

1:  mov (%rsp), %rax
    dup_
    mov 8(%rsp), %rax
    dup_
    mov _search+8(%rip), %rax
    call dfind
    test %rax, %rax
    jz 2f
    mov 8(%rax), %rax    # get CFA
    # discard saved string
    pop %rcx
    pop %rcx
    jmp *_action+8(%rip)

2:  mov (%rsp), %rax
    dup_
    mov 8(%rsp), %rax
    call number
    test %rax, %rax
    jnz 4f
    drop_

    # discard saved string
    pop %rcx
    pop %rcx
    jmp *_action+16(%rip)

4:  pop %rcx
    pop %rcx
    call *_action+24(%rip)
    drop_
    xor %rax, %rax
    jmp abort

dictrewind:
    call latest
    mov (%rax), %rax    # rax = [mf]latest
    mov (%rax), %rcx    # rcx = latest defined header in current dict
    mov (%rcx), %rdx    # rdx = next to latest defined header

    mov %rdx, (%rax)    # make next to latest the new latest
    drop_
    jmp stopcomp

execute:
    mov %rax, %rbx
    drop_
    jmp *%rbx

resetinput:
    xor %rcx, %rcx
    mov %rcx, _inused(%rip)
    mov %rcx, _inpos(%rip)
    ret

setreadkern:
    lea _kernbuf(%rip), %rcx
    mov %rcx, _inbuf(%rip)
    movq $_kerntot, _intot(%rip)
    movq $_kerntot, _inused(%rip)
    xor %rcx, %rcx
    mov %rcx, _inpos(%rip)
    ret

readloop:
    mov _inpos(%rip), %rcx
    mov _inused(%rip), %rdx
    cmp %rcx, %rdx
    jne 1f
    ret
1:  call nextword
    test %rax, %rax
    jnz 2f
    drop_
    drop_
    jmp readloop
2:  call eval
    call checkstacks
    jmp readloop

    .data
_banner:    .ascii "nop forth\n"
_blen =     . - _banner

    .text
banner:
    dup_
    lea _banner(%rip), %rax
    dup_
    mov $_blen, %rax
    jmp type

bye:
    xor %rax, %rax
    call sysexit

    .data
dstack: .space 8192, 0
dstack0: .quad 0

_R0: .quad 0             # return stack base
_S0: .quad 0             # parameter stack base
_Send: .quad 0           # parameter stack end

    .text

    .global boot
boot:
    mov %rsp, _R0(%rip)
    call resetstacks
    call resetdict
    call stopcomp
    call setreadkern
warm:
    call readloop
    jmp bye

resetstacks:
    #
    # we used dstack0+8 so as when something is pushed to S,
    # %rbp becomes dstack0
    #
    lea dstack0+8(%rip), %rbp
    mov %rbp, _S0(%rip)
    lea dstack(%rip), %rax
    mov %rax, _Send(%rip)

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
3:  call type
    dup_
    jmp abort

S0:
    dup_
    mov _S0(%rip), %rax
    ret

spfetch:
    dup_
    mov %rbp, %rax
    ret

resetdict:
    dup_
    push %rdx
    mov $0, %rdi         # addr
    mov $0x100000, %rsi  # length
    mov $(PROT_READ | PROT_WRITE | PROT_EXEC), %rdx  # prot
    mov $(MAP_ANONYMOUS | MAP_SHARED), %r10          # flags
    mov $-1, %r8         # fd
    mov $0, %r9          # offset (ignored)
    mov $SYSMMAP, %rax
    syscall
    pop %rdx
    jz 1f
    mov %rax, _h(%rip)
    drop_
    ret
1:
    mov $1, %rax
    call sysexit

Br:
    int3
    ret

    .data
.include "x86-64/dicts.s"

_kernbuf:
.incbin "portable/comments.ns"
.incbin "x86-64/base.ns"
.incbin "portable/base.ns"
_kerntot = . - _kernbuf
