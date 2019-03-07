    .data

#
# Forth
#
    .align 8
sysread_header:
    .quad 0
    .quad sysread
    .byte 7
    .ascii "sysread"

    .align 8
syswrite_header:
    .quad sysread_header
    .quad syswrite
    .byte 8
    .ascii "syswrite"

    .align 8
sysopen_header:
    .quad syswrite_header
    .quad sysopen
    .byte 7
    .ascii "sysopen"

    .align 8
sysclose_header:
    .quad sysopen_header
    .quad sysclose
    .byte 8
    .ascii "sysclose"

   .align 8
sysexit_header:
    .quad sysclose_header
    .quad sysexit
    .byte 7
    .ascii "sysexit"

    .align 8
sysmmap_header:
    .quad sysexit_header
    .quad sysmmap
    .byte 7
    .ascii "sysmmap"

    .align 8
expect_header:
    .quad sysmmap_header
    .quad expect
    .byte 6
    .ascii "expect"

    .align 8
type_header:
    .quad expect_header
    .quad type
    .byte 4
    .ascii "type"

    .align 8
emit_header:
    .quad type_header
    .quad emit
    .byte 4
    .ascii "emit"

    .align 8
key_header:
    .quad emit_header
    .quad key
    .byte 3
    .ascii "key"

    .align 8
skip_header:
    .quad key_header
    .quad skip
    .byte 4
    .ascii "skip"

    .align 8
scan_header:
    .quad skip_header
    .quad scan
    .byte 4
    .ascii "scan"

    .align 8
digit_header:
    .quad scan_header
    .quad digit
    .byte 5
    .ascii "digit"

    .align 8
number_header:
    .quad digit_header
    .quad number
    .byte 6
    .ascii "number"

    .align 8
inbuf_header:
    .quad number_header
    .quad inbuf
    .byte 5
    .ascii "inbuf"

    .align 8
word_header:
    .quad inbuf_header
    .quad word
    .byte 4
    .ascii "word"

    .align 8
flatest_header:
    .quad word_header
    .quad flatest
    .byte 7
    .ascii "flatest"

    .align 8
mlatest_header:
    .quad flatest_header
    .quad mlatest
    .byte 7
    .ascii "mlatest"

latest_header:
    .quad mlatest_header
    .quad latest
    .byte 6
    .ascii "latest"

macro_header:
    .quad latest_header
    .quad macro
    .byte 5
    .ascii "macro"

forth_header:
    .quad macro_header
    .quad forth
    .byte 5
    .ascii "forth"

    .align 8
dovar_header:
    .quad forth_header
    .quad dovar
    .byte 5
    .ascii "dovar"

    .align 8
comma_header:
    .quad dovar_header
    .quad comma
    .byte 1
    .ascii ","

    .align 8
comma4_header:
    .quad comma_header
    .quad comma4
    .byte 2
    .ascii "4,"

    .align 8
comma2_header:
    .quad comma4_header
    .quad comma2
    .byte 2
    .ascii "2,"

    .align 8
comma1_header:
    .quad comma2_header
    .quad comma1
    .byte 2
    .ascii "b,"

    .align 8
aligned_header:
    .quad comma1_header
    .quad aligned
    .byte 7
    .ascii "aligned"

    .align 8
centry_header:
    .quad aligned_header
    .quad centry
    .byte 6
    .ascii "centry"

    .align 8
entry_header:
    .quad centry_header
    .quad entry
    .byte 5
    .ascii "entry"

    .align 8
create_header:
    .quad entry_header
    .quad create
    .byte 6
    .ascii "create"

    .align 8
anon_header:
    .quad create_header
    .quad anon
    .byte 5
    .ascii "anon:"

    .align 8
dfind_header:
    .quad anon_header
    .quad dfind
    .byte 5
    .ascii "dfind"

    .align 8
tocfa_header:
    .quad dfind_header
    .quad tocfa
    .byte 4
    .ascii ">cfa"

    .align 8
h_header:
    .quad tocfa_header
    .quad h
    .byte 1
    .ascii "h"

    .align 8
here_header:
    .quad h_header
    .quad here
    .byte 4
    .ascii "here"

    .align 8
ccall_header:
    .quad here_header
    .quad ccall
    .byte 5
    .ascii "call,"

    .align 8
abortq_header:
    .quad ccall_header
    .quad abortq
    .byte 6
    .ascii "abort\""

    .align 8
abort_header:
    .quad abortq_header
    .quad abort
    .byte 5
    .ascii "abort"

    .align 8
eval_header:
    .quad abort_header
    .quad eval
    .byte 4
    .ascii "eval"

    .align 8
compile_header:
    .quad eval_header
    .quad compile
    .byte 7
    .ascii "compile"

    .align 8
execute_header:
    .quad compile_header
    .quad execute
    .byte 7
    .ascii "execute"

    .align 8
resetinput_header:
    .quad execute_header
    .quad resetinput
    .byte 11
    .ascii "reset-input"

    .align 8
qrefill_header:
    .quad resetinput_header
    .quad qrefill
    .byte 7
    .ascii "?refill"

    .align 8
refill_header:
    .quad qrefill_header
    .quad refill
    .byte 6
    .ascii "refill"

    .align 8
readloop_header:
    .quad refill_header
    .quad readloop
    .byte 8
    .ascii "readloop"

    .align 8
banner_header:
    .quad readloop_header
    .quad banner
    .byte 6
    .ascii "banner"

    .align 8
bye_header:
    .quad banner_header
    .quad bye
    .byte 3
    .ascii "bye"

    .align 8
dstack_header:
    .quad bye_header
    .quad dstack
    .byte 6
    .ascii ".space"

    .align 8
dstack0_header:
    .quad dstack_header
    .quad dstack0
    .byte 7
    .ascii "dstack0"

    .align 8
boot_header:
    .quad dstack0_header
    .quad boot
    .byte 4
    .ascii "boot"

    .align 8
resetstacks_header:
    .quad boot_header
    .quad resetstacks
    .byte 11
    .ascii "resetstacks"

    .align 8
checkstacks_header:
    .quad resetstacks_header
    .quad checkstacks
    .byte 11
    .ascii "checkstacks"

    .align 8
resetdict_header:
    .quad checkstacks_header
    .quad resetdict
    .byte 9
    .ascii "resetdict"

    .align 8
B_header:
    .quad resetdict_header
    .quad B
    .byte 1
    .ascii "B"

_flatest: .quad B_header

#
# Macro
#
    .align 8
stopcomp_header:
    .quad 0
    .quad stopcomp
    .byte 1
    .ascii "["

    .align 8
startcomp_header:
    .quad stopcomp_header
    .quad startcomp
    .byte 1
    .ascii "]"

    .align 8
cexit_header:
    .quad startcomp_header
    .quad cexit
    .byte 4
    .ascii "exit"

    .align 8
semicolon_header:
    .quad cexit_header
    .quad semicolon
    .byte 1
    .ascii ";"

    .align 8
colon_header:
    .quad semicolon_header
    .quad colon
    .byte 1
    .ascii ":"

    .align 8
cdup_header:
    .quad colon_header
    .quad cdup
    .byte 3
    .ascii "dup"

    .align 8
cdrop_header:
    .quad cdup_header
    .quad cdrop
    .byte 4
    .ascii "drop"

    .align 8
cswap_header:
    .quad cdrop_header
    .quad cswap
    .byte 4
    .ascii "swap"

    .align 8
cover_header:
    .quad cswap_header
    .quad cover
    .byte 4
    .ascii "over"

    .align 8
cpush_header:
    .quad cover_header
    .quad cpush
    .byte 4
    .ascii "push"

    .align 8
cpop_header:
    .quad cpush_header
    .quad cpop
    .byte 3
    .ascii "pop"

    .align 8
cfetch_header:
    .quad cpop_header
    .quad cfetch
    .byte 1
    .ascii "@"

    .align 8
cbfetch_header:
    .quad cfetch_header
    .quad cbfetch
    .byte 2
    .ascii "b@"

    .align 8
cstore_header:
    .quad cbfetch_header
    .quad cstore
    .byte 1
    .ascii "!"

    .align 8
cbstore_header:
    .quad cstore_header
    .quad cbstore
    .byte 2
    .ascii "b!"

    .align 8
cadd_header:
    .quad cbstore_header
    .quad cadd
    .byte 1
    .ascii "+"

    .align 8
csub_header:
    .quad cadd_header
    .quad csub
    .byte 1
    .ascii "-"

    .align 8
cmul_header:
    .quad csub_header
    .quad cmul
    .byte 1
    .ascii "*"

    .align 8
cdivmod_header:
    .quad cmul_header
    .quad cdivmod
    .byte 4
    .ascii "/mod"

    .align 8
ceq_header:
    .quad cdivmod_header
    .quad ceq
    .byte 1
    .ascii "="

    .align 8
clt_header:
    .quad ceq_header
    .quad clt
    .byte 1
    .ascii "<"

    .align 8
cgt_header:
    .quad clt_header
    .quad cgt
    .byte 1
    .ascii ">"

    .align 8
cne_header:
    .quad cgt_header
    .quad cne
    .byte 2
    .ascii "/="

    .align 8
cle_header:
    .quad cne_header
    .quad cle
    .byte 2
    .ascii "<="

    .align 8
cge_header:
    .quad cle_header
    .quad cge
    .byte 2
    .ascii ">="

    .align 8
clit_header:
    .quad cge_header
    .quad clit
    .byte 3
    .ascii "lit"

   .align 8
cif_header:
    .quad clit_header
    .quad cif
    .byte 2
    .ascii "if"

    .align 8
cjump_header:
    .quad cif_header
    .quad cjump
    .byte 4
    .ascii "jump"

_mlatest: .quad cjump_header
