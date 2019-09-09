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
sysexit_header:
    .quad syswrite_header
    .quad sysexit
    .byte 7
    .ascii "sysexit"

   .align 8
_dlclose_header:
    .quad sysexit_header
    .quad _dlclose
    .byte 7
    .ascii "dlclose"

   .align 8
_dlerror_header:
    .quad _dlclose_header
    .quad _dlerror
    .byte 7
    .ascii "dlerror"

   .align 8
_dlsym_header:
    .quad _dlerror_header
    .quad _dlsym
    .byte 5
    .ascii "dlsym"

   .align 8
_dlopen_header:
    .quad _dlsym_header
    .quad _dlopen
    .byte 6
    .ascii "dlopen"

   .align 8
syscall5_header:
    .quad _dlopen_header
    .quad syscall5
    .byte 8
    .ascii "syscall5"

   .align 8
syscall4_header:
    .quad syscall5_header
    .quad syscall4
    .byte 8
    .ascii "syscall4"

   .align 8
syscall3_header:
    .quad syscall4_header
    .quad syscall3
    .byte 8
    .ascii "syscall3"

   .align 8
syscall2_header:
    .quad syscall3_header
    .quad syscall2
    .byte 8
    .ascii "syscall2"

   .align 8
syscall1_header:
    .quad syscall2_header
    .quad syscall1
    .byte 8
    .ascii "syscall1"

    .align 8
expect_header:
    .quad syscall1_header
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
termkey_header:
    .quad emit_header
    .quad termkey
    .byte 7
    .ascii "termkey"

    .align 8
keyxt_header:
    .quad termkey_header
    .quad keyxt
    .byte 4
    .ascii "'key"

    .align 8
key_header:
    .quad keyxt_header
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
base_header:
    .quad number_header
    .quad base
    .byte 4
    .ascii "base"

    .align 8
infd_header:
    .quad base_header
    .quad infd
    .byte 4
    .ascii "infd"

    .align 8
inbuf_header:
    .quad infd_header
    .quad inbuf
    .byte 5
    .ascii "inbuf"

    .align 8
intot_header:
    .quad inbuf_header
    .quad intot
    .byte 5
    .ascii "intot"

    .align 8
inused_header:
    .quad intot_header
    .quad inused
    .byte 6
    .ascii "inused"

    .align 8
inpos_header:
    .quad inused_header
    .quad inpos
    .byte 5
    .ascii "inpos"

    .align 8
termbuf_header:
    .quad inpos_header
    .quad termbuf
    .byte 7
    .ascii "termbuf"

    .align 8
termtot_header:
    .quad termbuf_header
    .quad termtot
    .byte 7
    .ascii "termtot"

    .align 8
source_header:
    .quad termtot_header
    .quad source
    .byte 6
    .ascii "source"

    .align 8
nextword_header:
    .quad source_header
    .quad nextword
    .byte 9
    .ascii "next-word"

    .align 8
word_header:
    .quad nextword_header
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

    .align 8
latest_header:
    .quad mlatest_header
    .quad latest
    .byte 6
    .ascii "latest"

    .align 8
hole_header:
    .quad latest_header
    .quad hole
    .byte 4
    .ascii "hole"

    .align 8
macro_header:
    .quad hole_header
    .quad macro
    .byte 5
    .ascii "macro"

forth_header:
    .quad macro_header
    .quad forth
    .byte 5
    .ascii "forth"

    .align 8
comma_header:
    .quad forth_header
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
comma3_header:
    .quad comma4_header
    .quad comma3
    .byte 2
    .ascii "3,"

    .align 8
comma2_header:
    .quad comma3_header
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
    .ascii "entry,"

    .align 8
entry_header:
    .quad centry_header
    .quad entry
    .byte 5
    .ascii "entry"

    .align 8
anon_header:
    .quad entry_header
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
abort_header:
    .quad ccall_header
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
execute_header:
    .quad eval_header
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
refillxt_header:
    .quad resetinput_header
    .quad refillxt
    .byte 7
    .ascii "'refill"

    .align 8
qrefill_header:
    .quad refillxt_header
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
termrefill_header:
    .quad refill_header
    .quad termrefill
    .byte 10
    .ascii "termrefill"

    .align 8
readloop_header:
    .quad termrefill_header
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
okprompt_header:
    .quad banner_header
    .quad okprompt
    .byte 8
    .ascii "okprompt"

    .align 8
promptxt_header:
    .quad okprompt_header
    .quad promptxt
    .byte 7
    .ascii "'prompt"

    .align 8
bye_header:
    .quad promptxt_header
    .quad bye
    .byte 3
    .ascii "bye"

    .align 8
resetstacks_header:
    .quad bye_header
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
S0_header:
    .quad checkstacks_header
    .quad S0
    .byte 2
    .ascii "S0"

    .align 8
spfetch_header:
    .quad S0_header
    .quad spfetch
    .byte 3
    .ascii "sp@"

    .align 8
resetdict_header:
    .quad spfetch_header
    .quad resetdict
    .byte 9
    .ascii "resetdict"

    .align 8
Br_header:
    .quad resetdict_header
    .quad Br
    .byte 2
    .ascii "Br"

_flatest: .quad Br_header

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
cnip_header:
    .quad cswap_header
    .quad cnip
    .byte 3
    .ascii "nip"

    .align 8
cover_header:
    .quad cnip_header
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
ca_header:
    .quad cpop_header
    .quad ca
    .byte 1
    .ascii "a"

    .align 8
castore_header:
    .quad ca_header
    .quad castore
    .byte 2
    .ascii "a!"

    .align 8
cfetch_header:
    .quad castore_header
    .quad cfetch
    .byte 1
    .ascii "@"

cfetchplus_header:
    .quad cfetch_header
    .quad cfetchplus
    .byte 2
    .ascii "@+"

    .align 8
cbfetch_header:
    .quad cfetchplus_header
    .quad cbfetch
    .byte 2
    .ascii "b@"

cbfetchplus_header:
    .quad cbfetch_header
    .quad cbfetchplus
    .byte 3
    .ascii "b@+"

    .align 8
cstore_header:
    .quad cbfetchplus_header
    .quad cstore
    .byte 1
    .ascii "!"

    .align 8
cstoreplus_header:
    .quad cstore_header
    .quad cstoreplus
    .byte 2
    .ascii "!+"

    .align 8
cbstore_header:
    .quad cstoreplus_header
    .quad cbstore
    .byte 2
    .ascii "b!"

    .align 8
cbstoreplus_header:
    .quad cbstore_header
    .quad cbstoreplus
    .byte 3
    .ascii "b!+"

    .align 8
cadd_header:
    .quad cbstoreplus_header
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
cor_header:
    .quad cdivmod_header
    .quad cor
    .byte 2
    .ascii "or"

    .align 8
cand_header:
    .quad cor_header
    .quad cand
    .byte 3
    .ascii "and"

    .align 8
cxor_header:
    .quad cand_header
    .quad cxor
    .byte 3
    .ascii "xor"

    .align 8
cnot_header:
    .quad cxor_header
    .quad cnot
    .byte 3
    .ascii "not"

    .align 8
ceq_header:
    .quad cnot_header
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
