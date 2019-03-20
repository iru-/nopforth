macro
: \  refill drop ;
: (  41 word drop drop ;

: then  ( a -> )  0 hole !  here  over 1 + -  swap b! ;

forth
: dup   dup ;
: drop  drop ;
: swap  swap ;
: over  over ;
: nip   nip ;

: a     a ;
: a!    a! ;
: @     @ ;
: @+    @+ ;
: b@    b@ ;
: b@+   b@+ ;
: !     ! ;
: !+    !+ ;
: b!    b! ;
: b!+   b!+ ;

: +     + ;
: -     - ;
: /mod  /mod ;
: /     /mod nip ;
: mod   /mod drop ;

: bl  32 ;
: cr  10 emit ;

: decimal  10 base ! ;
: hex      16 base ! ;

: char  bl word drop b@ ;

hex
: reljmp,  ( dst src -> )  5 + -  E9 b, 4, ;
decimal

: found  ( a u -> a'|0 )     latest dfind ;
: find  ( "name" -> a' )     bl word found ;
: '  ( "name" -> a'|0 )      find dup 0 = if abort then >cfa @ ;

macro
hex
: negate  ( n -> n' )  D8F748 3, ;  \ neg %rax

: [compile]  ( "name" -> )
  bl word mlatest dfind dup if >cfa @ call, exit then drop ;

: begin  ( -> 'begin )  here ;
: while  ( 'begin -> 'if 'begin )  [compile] if swap ;
: again  ( 'begin -> )  here reljmp, ;
: repeat  ( 'if 'begin -> )  [compile] again [compile] then ;

: for
  [compile] begin [compile] dup
  [compile] while [compile] push ;

: next
  [compile] pop    1 [compile] lit  [compile] -
  [compile] repeat  [compile] drop ;


: [char]  bl word drop b@ [compile] lit ;
: [']     ' [compile] lit ;

: r@  [compile] dup  24048B48 4, ;  \ mov (%rsp), %rax

forth

( Dictionary )
: +!  ( n a -> )  swap over  @ +  swap ! ;

: dovar    ( -> a )    pop ;
: created  ( a u -> )  entry, ['] dovar call, ;
: create               bl word created ;

: (value)  pop @ ;
: value  ( n -> )  entry ['] (value) call, , ;
: to  ( n -> )  ' 5 + ! ;

: variable  create 0 , ;

: allot  ( n -> )  here +  h ! ;


( Strings )
: /string  ( a u n -> a+n u-n )  swap over  - push + pop ;

: move  ( src dst u -> )
  push push a! pop pop
  begin dup while
    over b@+ swap b!
    1 /string
  repeat
  drop drop ;

: ,"  ( -> u )  [char] " word  dup push  here swap move  pop ;
: z"  ( -> u )  ,"  0 over here + b!  1 + ;
: s>z  ( a u -> )  dup push  here swap move  0 here pop + b! ;

: ."  [char] " word type ;

( File )
: (open-create)  ( a u mode n# -> fd )  push push s>z here pop pop syscall2 ;
: create-file  ( a u mode -> fd )  85 (open-create) ;
: open-file  ( a u mode -> fd )  2 (open-create) ;
: read-file  ( a u fd -> u )  sysread ;
: close-file  ( fd -> u )  3 syscall1 ;
: position-file  ( n rel? fd -> n' )  swap push swap pop 8 syscall3 ;
: file-position  ( fd -> n' )  push 0 1 pop position-file ;


256 value /buf
create   buf  /buf allot
variable fd

: input@  ( -> fd buf tot used pos )
  infd @ inbuf @ intot @ inused @ inpos @ ;

: input!  ( fd buf tot used pos -> )
  inpos ! inused ! intot ! inbuf ! infd ! ;

: included  ( a u -> )
  push push input@ pop pop
  0 open-file dup 0 < if abort then
  dup buf /buf 0 0 input!  readloop
  close-file drop  input! ;

: include  ( "name" -> )  bl word included ;


( Pictured numeric conversion )
decimal
: digit  ( n -> n' )  dup 9 >  if  7 +  then  48 + ;

: hold  ( count rem b -> b count+1 rem )  swap push  swap 1 + pop ;

: <#  ( n -> 0 n )    0 swap ;
: #   ( n -> ... count rem )  base @ /mod swap digit hold ;
: #>  ( ... count rem -> a u )  drop  here a!  dup push for b!+ next  here pop ;
: #s  ( n -> ... count rem )  begin # dup while repeat ;

: negate  negate ;
: abs  ( n -> |n| )  dup 0 < if negate then ;
: sign  0 < if  [char] - hold  then ;

: space  bl emit ;
: (.)  dup push abs <#  #s pop sign  #> ;
: .  (.) type space ;
