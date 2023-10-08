# SPDX-License-Identifier: MIT
# Copyright (c) 2018-2022 Iruatã Martins dos Santos Souza

    .data

#
# Forth
#
    .align 8
errno_header:
    .quad 0
    .quad syserrno
    .byte 5
    .ascii "errno"

    .align 8
read_header:
    .quad errno_header
    .quad sysread
    .byte 4
    .ascii "read"

    .align 8
write_header:
    .quad read_header
    .quad syswrite
    .byte 5
    .ascii "write"

    .align 8
sysexit_header:
    .quad write_header
    .quad sysexit
    .byte 7
    .ascii "sysexit"

    .align 8
open_header:
    .quad sysexit_header
    .quad sysopen
    .byte 4
    .ascii "open"

    .align 8
creat_header:
    .quad open_header
    .quad syscreat
    .byte 5
    .ascii "creat"

    .align 8
close_header:
    .quad creat_header
    .quad sysclose
    .byte 5
    .ascii "close"

    .align 8
lseek_header:
    .quad close_header
    .quad syslseek
    .byte 5
    .ascii "lseek"

    .align 8
mmap_header:
    .quad lseek_header
    .quad sysmmap
    .byte 4
    .ascii "mmap"

    .align 8
munmap_header:
    .quad mmap_header
    .quad sysmunmap
    .byte 6
    .ascii "munmap"

    .align 8
dlclose_header:
    .quad munmap_header
    .quad sysdlclose
    .byte 7
    .ascii "dlclose"

    .align 8
dlerror_header:
    .quad dlclose_header
    .quad sysdlerror
    .byte 7
    .ascii "dlerror"

    .align 8
dlsym_header:
    .quad dlerror_header
    .quad sysdlsym
    .byte 5
    .ascii "dlsym"

    .align 8
dlopen_header:
    .quad dlsym_header
    .quad sysdlopen
    .byte 6
    .ascii "dlopen"

    .align 8
malloc_header:
    .quad dlopen_header
    .quad sysmalloc
    .byte 6
    .ascii "malloc"

    .align 8
realloc_header:
    .quad malloc_header
    .quad sysrealloc
    .byte 7
    .ascii "realloc"

    .align 8
free_header:
    .quad realloc_header
    .quad sysfree
    .byte 4
    .ascii "free"

    .align 8
syscall6_header:
    .quad free_header
    .quad syscall6
    .byte 8
    .ascii "syscall6"

    .align 8
syscall5_header:
    .quad syscall6_header
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
keyxt_header:
    .quad type_header
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
skipws_header:
    .quad key_header
    .quad skipws
    .byte 6
    .ascii "skipws"

    .align 8
scanws_header:
    .quad skipws_header
    .quad scanws
    .byte 6
    .ascii "scanws"

    .align 8
skip_header:
    .quad scanws_header
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
infd_header:
    .quad number_header
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
source_header:
    .quad inpos_header
    .quad source
    .byte 6
    .ascii "source"

    .align 8
word_header:
    .quad source_header
    .quad word
    .byte 4
    .ascii "word"

    .align 8
parse_header:
    .quad word_header
    .quad parse
    .byte 5
    .ascii "parse"

    .align 8
flatest_header:
    .quad parse_header
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

    .align 8
forth_header:
    .quad macro_header
    .quad forth
    .byte 5
    .ascii "forth"

    .align 8
storeinstr_header:
    .quad forth_header
    .quad storeinstr
    .byte 2
    .ascii "i!"

    .align 8
storeinstr4_header:
    .quad storeinstr_header
    .quad storeinstr4
    .byte 3
    .ascii "i4!"

    .align 8
storeinstr2_header:
    .quad storeinstr4_header
    .quad storeinstr2
    .byte 3
    .ascii "i2!"

    .align 8
storeinstr1_header:
    .quad storeinstr2_header
    .quad storeinstr1
    .byte 3
    .ascii "i1!"

    .align 8
cinstr_header:
    .quad storeinstr1_header
    .quad cinstr
    .byte 2
    .ascii "i,"

    .align 8
cinstr4_header:
    .quad cinstr_header
    .quad cinstr4
    .byte 3
    .ascii "i4,"

    .align 8
cinstr2_header:
    .quad cinstr4_header
    .quad cinstr2
    .byte 3
    .ascii "i2,"

    .align 8
cinstr1_header:
    .quad cinstr2_header
    .quad cinstr1
    .byte 3
    .ascii "i1,"

    .align 8
comma_header:
    .quad cinstr1_header
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
    .ascii "1,"

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
codep_header:
    .quad here_header
    .quad codep
    .byte 5
    .ascii "codep"

    .align 8
ccall_header:
    .quad codep_header
    .quad ccall
    .byte 5
    .ascii "call,"

    .align 8
abortxt_header:
    .quad ccall_header
    .quad abortxt
    .byte 6
    .ascii "'abort"

    .align 8
abort_header:
    .quad abortxt_header
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
readloop_header:
    .quad resetinput_header
    .quad readloop
    .byte 8
    .ascii "readloop"

    .align 8
bye_header:
    .quad readloop_header
    .quad bye
    .byte 3
    .ascii "bye"

    .align 8
args_header:
    .quad bye_header
    .quad args
    .byte 4
    .ascii "args"

    .align 8
nargs_header:
    .quad args_header
    .quad nargs
    .byte 5
    .ascii "#args"

    .align 8
interpname_header:
    .quad nargs_header
    .quad interpname
    .byte 10
    .ascii "interpname"

    .align 8
sysgetenv_header:
    .quad interpname_header
    .quad sysgetenv
    .byte 8
    .ascii "(getenv)"

    .align 8
resetstacks_header:
    .quad sysgetenv_header
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

    .align 8
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

    .align 8
cfetchplus_header:
    .quad cfetch_header
    .quad cfetchplus
    .byte 2
    .ascii "@+"

    .align 8
c1fetch_header:
    .quad cfetchplus_header
    .quad c1fetch
    .byte 2
    .ascii "1@"

    .align 8
c1fetchplus_header:
    .quad c1fetch_header
    .quad c1fetchplus
    .byte 3
    .ascii "1@+"

    .align 8
cstore_header:
    .quad c1fetchplus_header
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
c1store_header:
    .quad cstoreplus_header
    .quad c1store
    .byte 2
    .ascii "1!"

    .align 8
c1storeplus_header:
    .quad c1store_header
    .quad c1storeplus
    .byte 3
    .ascii "1!+"

    .align 8
cadd_header:
    .quad c1storeplus_header
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
clnot_header:
    .quad cxor_header
    .quad clnot
    .byte 1
    .ascii "~"

    .align 8
ceq_header:
    .quad clnot_header
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
    .ascii "~="

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
_mlatest: .quad clit_header
