.include "macros.inc"

#
# Tests
#
    .data
oks: .ascii "ok\n"
okslen = . - oks

errs: .ascii "err\n"
errslen = . - errs

    .text
tok:
    dup_
    lea oks(%rip), %rax
    dup_
    mov $okslen, %rax
    call type
    ret

terr:
    dup_
    lea errs(%rip), %rax
    dup_
    mov $errslen, %rax
    call type
    mov $1, %rax
    call sysexit

    .data
B1: .ascii "abc de"
B1len = . - B1

B2: .ascii "  abc de"
B2len = . - B2

B3: .ascii "abcde "
B3len =  . - B3

B4: .ascii "e"
B4len = . - B4

    .text
alltests:

testscan:
    mov $' ', %rax
    dup_    
    lea B1(%rip), %rax
    dup_
    mov $B1len, %rax
    call scan
    mov %rax, %rcx
    drop_
    cmpq $(B1len-3), %rcx
    jnz terr
    lea B1(%rip), %rcx
    lea 3(%rcx), %rcx
    cmpq %rcx, %rax
    jnz terr
    call tok

    mov $' ', %rax
    dup_    
    lea B2(%rip), %rax
    dup_
    mov $B2len, %rax
    call scan
    mov %rax, %rcx           # rcx = remaining length
    drop_                    # rax = string address
    cmpq $B2len, %rcx
    jnz terr
    lea B2(%rip), %rcx
    cmpq %rcx, %rax
    jnz terr
    call tok

    mov $' ', %rax
    dup_    
    lea B3(%rip), %rax
    dup_
    mov $B3len, %rax
    call scan
    mov %rax, %rcx           # rcx = remaining length
    drop_                    # rax = string address
    cmpq $1, %rcx
    jnz terr
    lea B3(%rip), %rcx
    lea B3len-1(%rcx), %rcx
    cmpq %rcx, %rax
    jnz terr
    call tok

    mov $'z', %rax
    dup_    
    lea B1(%rip), %rax
    dup_
    mov $B1len, %rax
    call scan
    mov %rax, %rcx           # rcx = remaining length
    drop_                    # rax = string address
    cmpq $0, %rcx
    jnz terr
    lea B1(%rip), %rcx
    lea B1len(%rcx), %rcx
    cmpq %rcx, %rax
    jnz terr
    call tok

testskip:
    dup_
    mov $' ', %rax
    dup_    
    lea B2(%rip), %rax
    dup_
    mov $B2len, %rax
    call skip
    mov %rax, %rcx           # rcx = remaining length
    drop_                    # rax = string address
    cmpq $(B2len-2), %rcx
    jnz terr
    lea B2(%rip), %rcx
    add $2, %rcx
    cmpq %rcx, %rax
    jnz terr
    drop_
    call tok

    dup_
    mov $' ', %rax
    dup_    
    lea B1(%rip), %rax
    dup_
    mov $B1len, %rax
    call skip
    mov %rax, %rcx           # rcx = remaining length
    drop_                    # rax = string address
    cmpq $B1len, %rcx
    jnz terr
    lea B1(%rip), %rcx
    cmpq %rcx, %rax
    jnz terr
	drop_
    call tok

	dup_
    mov $' ', %rax
    dup_    
    lea B1(%rip), %rax
    lea 3(%rax), %rax
    dup_
    mov $B1len-3, %rax
    call skip
    mov %rax, %rcx           # rcx = remaining length
    drop_                    # rax = string address
    cmpq $2, %rcx
    jnz terr
    lea B1(%rip), %rcx
    lea B1len-2(%rcx), %rcx
    cmpq %rcx, %rax
    jnz terr
	drop_
    call tok

    dup_
    mov $' ', %rax
    dup_    
    lea B3(%rip), %rax
    lea B3len-1(%rax), %rax
    dup_
    mov $1, %rax
    call skip
    mov %rax, %rcx           # rcx = remaining length
    drop_                    # rax = string address
    cmpq $0, %rcx
    jnz terr
    lea B3(%rip), %rcx
    lea B3len(%rcx), %rcx
    cmpq %rcx, %rax
    jnz terr
	drop_
    call tok

    dup_
    mov $' ', %rax
    dup_
    lea B4(%rip), %rax
    dup_
    mov $1, %rax
    call skip
	mov %rax, %rcx
	drop_
	cmpq $1, %rcx
	jnz terr
	lea B4(%rip), %rcx
	cmp %rcx, %rax
	jnz terr
	drop_
	call tok

	dup_
    mov $' ', %rax
    dup_
    lea B4(%rip), %rax
    dup_
    mov $0, %rax
    call skip
	mov %rax, %rcx
	drop_
	cmpq $0, %rcx
	jnz terr
	lea B4(%rip), %rcx
	cmp %rcx, %rax
	jnz terr
	drop_
	call tok
	ret

testinbuf:
    movw $5, _inbuflen(%rip)
    mov %rcx, (%rbp)

    movw $0, _inpos(%rip)
    call inbuf
    cmp $5, %rax
    jnz terr
    drop_
    lea _inbuf(%rip), %rcx
    cmp %rax, %rcx
    jnz terr
    call tok

    movw $4, _inpos(%rip)
    call inbuf
    cmp $0, %rax
    jnz terr
    drop_
    lea _inbuf+4(%rip), %rcx
    cmp %rax, %rcx
    jnz terr
    call tok
    
    movw $5, _inpos(%rip)
    call inbuf
    cmp $0, %rax
    jnz terr
    drop_
    lea _inbuf+5(%rip), %rcx
    cmp %rax, %rcx
    jnz terr
    call tok

testdigit:
    movb $10, _base(%rip)
    mov $'5', %rax
    call digit
    cmp $5, %rax
    jne terr
    call tok

    movb $16, _base(%rip)
    mov $'A', %rax
    call digit
    cmp $10, %rax
    jne terr
    call tok

    mov $'a', %rax
    call digit
    cmp $-1, %rax
    jne terr
    call tok

    .data
_pdec: .ascii "12345"
_ndec: .ascii "-1234"
_hex:  .ascii "DBEEF"

    .text
testnumber:
    movb $10, _base(%rip)

    lea _pdec(%rip), %rax
    dup_
    mov $5, %rax
    call number
    cmp $0, %rax
    jne terr
    drop_
    cmp $12345, %rax
    jne terr
    call tok

    lea _ndec(%rip), %rax
    dup_
    mov $5, %rax
    call number
    cmp $0, %rax
    jne terr
    drop_
    cmp $-1234, %rax
    jne terr
    call tok

    lea _hex(%rip), %rax
    dup_
    mov $5, %rax
    call number
    cmp $5, %rax
    jne terr
    drop_
    cmp $5, %rax
    jne terr
    call tok

    movb $16, _base(%rip)
  
    lea _hex(%rip), %rax
    dup_
    mov $5, %rax
    call number
    cmp $0, %rax
    jne terr
    drop_
    cmp $0xDBEEF, %rax
    jne terr
    call tok

    xor %rax, %rax
    call sysexit
