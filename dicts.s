    .data

#
# Forth
#
    .align 8
sysread_header:
    .quad 0
    .byte 7
    .ascii "sysread"
    .quad sysread

    .align 8
syswrite_header:
    .quad sysread_header
    .byte 8
    .ascii "syswrite"
    .quad syswrite

    .align 8
sysexit_header:
    .quad syswrite_header
    .byte 7
    .ascii "sysexit"
    .quad sysexit

    .align 8
sysmmap_header:
    .quad sysexit_header
    .byte 7
    .ascii "sysmmap"
    .quad sysmmap

    .align 8
expect_header:
    .quad sysmmap_header
    .byte 6
    .ascii "expect"
    .quad expect

    .align 8
type_header:
    .quad expect_header
    .byte 4
    .ascii "type"
    .quad type

    .align 8
emit_header:
    .quad type_header
    .byte 4
    .ascii "emit"
    .quad emit

    .align 8
key_header:
    .quad emit_header
    .byte 3
    .ascii "key"
    .quad key

    .align 8
skip_header:
    .quad key_header
    .byte 4
    .ascii "skip"
    .quad skip

    .align 8
scan_header:
    .quad skip_header
    .byte 4
    .ascii "scan"
    .quad scan

    .align 8
digit_header:
    .quad scan_header
    .byte 5
    .ascii "digit"
    .quad digit

    .align 8
number_header:
    .quad digit_header
    .byte 6
    .ascii "number"
    .quad number

    .align 8
inbuf_header:
    .quad number_header
    .byte 5
    .ascii "inbuf"
    .quad inbuf

    .align 8
infrom_header:
    .quad inbuf_header
    .byte 3
    .ascii "in>"
    .quad infrom

    .align 8
word_header:
    .quad infrom_header
    .byte 4
    .ascii "word"
    .quad word

    .align 8
flatest_header:
    .quad word_header
    .byte 7
    .ascii "flatest"
    .quad flatest

    .align 8
mlatest_header:
    .quad flatest_header
    .byte 7
    .ascii "mlatest"
    .quad mlatest

latest_header:
    .quad mlatest_header
    .byte 6
    .ascii "latest"
    .quad latest

macro_header:
    .quad latest_header
    .byte 5
    .ascii "macro"
    .quad macro

forth_header:
    .quad macro_header
    .byte 5
    .ascii "forth"
    .quad forth

    .align 8
dolit_header:
    .quad forth_header
    .byte 5
    .ascii "dolit"
    .quad dolit

    .align 8
comma_header:
    .quad dolit_header
    .byte 1
    .ascii ","
    .quad comma

    .align 8
comma4_header:
    .quad comma_header
    .byte 2
    .ascii "4,"
    .quad comma4

    .align 8
comma1_header:
    .quad comma4_header
    .byte 2
    .ascii "b,"
    .quad comma1

    .align 8
create_header:
    .quad comma1_header
    .byte 6
    .ascii "create"
    .quad create

    .align 8
dfind_header:
    .quad create_header
    .byte 5
    .ascii "dfind"
    .quad dfind

    .align 8
tocfa_header:
    .quad dfind_header
    .byte 4
    .ascii ">cfa"
    .quad tocfa

    .align 8
here_header:
    .quad tocfa_header
    .byte 4
    .ascii "here"
    .quad here

    .align 8
ccall_header:
    .quad here_header
    .byte 5
    .ascii "call,"
    .quad ccall

    .align 8
abortq_header:
    .quad ccall_header
    .byte 6
    .ascii "abort\""
    .quad abortq

    .align 8
abort_header:
    .quad abortq_header
    .byte 5
    .ascii "abort"
    .quad abort

    .align 8
eval_header:
    .quad abort_header
    .byte 4
    .ascii "eval"
    .quad eval

    .align 8
compile_header:
    .quad eval_header
    .byte 7
    .ascii "compile"
    .quad compile

    .align 8
execute_header:
    .quad compile_header
    .byte 7
    .ascii "execute"
    .quad execute

    .align 8
readloop_header:
    .quad execute_header
    .byte 8
    .ascii "readloop"
    .quad readloop

    .align 8
parseloop_header:
    .quad readloop_header
    .byte 9
    .ascii "parseloop"
    .quad parseloop

    .align 8
banner_header:
    .quad parseloop_header
    .byte 6
    .ascii "banner"
    .quad banner

    .align 8
bye_header:
    .quad banner_header
    .byte 3
    .ascii "bye"
    .quad bye

    .align 8
dstack_header:
    .quad bye_header
    .byte 6
    .ascii ".space"
    .quad dstack

    .align 8
dstack0_header:
    .quad dstack_header
    .byte 7
    .ascii "dstack0"
    .quad dstack0

    .align 8
boot_header:
    .quad dstack0_header
    .byte 4
    .ascii "boot"
    .quad boot

    .align 8
resetstacks_header:
    .quad boot_header
    .byte 11
    .ascii "resetstacks"
    .quad resetstacks

    .align 8
checkstacks_header:
    .quad resetstacks_header
    .byte 11
    .ascii "checkstacks"
    .quad checkstacks

    .align 8
resetdict_header:
    .quad checkstacks_header
    .byte 9
    .ascii "resetdict"
    .quad resetdict

    .align 8
add_header:
    .quad resetdict_header
    .byte 1
    .ascii "+"
    .quad add

    .align 8
sub_header:
    .quad add_header
    .byte 1
    .ascii "-"
    .quad sub

_flatest: .quad sub_header

#
# Macro
#
    .align 8
stopcomp_header:
    .quad 0
    .byte 1
    .ascii "["
    .quad stopcomp

    .align 8
startcomp_header:
    .quad stopcomp_header
    .byte 1
    .ascii "]"
    .quad startcomp

    .align 8
cexit_header:
    .quad startcomp_header
    .byte 4
    .ascii "exit"
    .quad cexit

    .align 8
semicolon_header:
    .quad cexit_header
    .byte 1
    .ascii ";"
    .quad semicolon

    .align 8
colon_header:
    .quad semicolon_header
    .byte 1
    .ascii ":"
    .quad colon

_mlatest: .quad colon_header
