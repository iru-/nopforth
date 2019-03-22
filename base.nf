macro
: \  refill drop ;
: (  41 word drop drop ;

: decimal  10 base ! ;
: hex      16 base ! ;


( Control flow )
macro hex
: then  0 hole !  here  over 1 + -  swap b! ;

forth
: entry>call,  ( a -> )  >cfa @ call, ;
macro

: [compile]  ( "<spaces>name<space>" -> )
  20 word over over
  mlatest dfind dup if  entry>call, drop drop exit  then drop
  flatest dfind dup if  entry>call, exit  then drop abort ;

: r@     [compile] dup  24048B48 4, ;  \ mov (%rsp), %rax
: rdrop  48 b, 0824648D 4, ;  \ lea 8(%rsp), %rsp

: asave  [compile] a    [compile] push ;
: arest  [compile] pop  [compile] a! ;

: begin   here ;
: while   [compile] if swap ;
: again   here 5 + -  E9 b, 4, ;
: repeat  [compile] again [compile] then ;

: for   [compile] push [compile] begin [compile] r@ [compile] while ;
: next
  240CFF48 4,  \ decq (%rsp)
  [compile] repeat [compile] rdrop ;


( macro -> forth )
\ We define forth words using the macros, so they can be used interactively
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


( Dictionary )
forth hex
: found  ( a u -> a'|0 )  latest dfind ;
: find  ( "name" -> a' )  20 word found ;
: '  ( "name" -> a'|0 )   find dup 0 = if abort then >cfa @ ;

macro
: [']  '  [compile] lit ;
forth

: allot  ( n -> )  here +  h ! ;

: dovar                pop ;
: created  ( a u -> )  entry, ['] dovar call, ;
: create               20 word created ;

: variable  create 0 , ;

: (value)  pop @ ;
: value  ( n -> )  entry ['] (value) call, , ;
: to  ( n -> )  ' 5 + ! ;
macro
: to  ' 5 +  [compile] lit  [compile] ! ;
forth


( Memory utilities )
forth
: advance  ( a u n -> a+n u-n )  swap over  - push + pop ;

: move  ( src dst u -> )
  push push a! pop pop
  begin dup while
    over b@+ swap b!
    1 advance
  repeat
  drop drop ;

: +!  ( n a -> )  swap over  @ +  swap ! ;


( Strings )
forth decimal
: cr  10 emit ;
: bl  32 ;

: char  bl word drop b@ ;
macro
: [char]  bl word drop b@ [compile] lit ;
forth


( Strings )
forth
: ,"  ( -> u )  [char] " word  dup push  here swap move  pop ;
: z"  ( -> u )  ,"  0 over here + b!  1 + ;
: s>z  ( a u -> )  dup push  here swap move  0 here pop + b! ;

: ."  [char] " word type ;


( File )
forth decimal
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
macro hex
: negate  ( n -> n' )  D8F748 3, ;  \ neg %rax

forth decimal
: digit  ( n -> n' )  dup 9 >  7 and +  48 + ;

: hold  ( count rem b -> b count+1 rem )  swap push  swap 1 + pop ;

: <#  ( n -> 0 n )    0 swap ;
: #   ( n -> ... count rem )  base @ /mod swap digit hold ;
: #>  ( ... count rem -> a u )  asave  drop  here a!  dup push for b!+ next  here pop  arest ;
: #s  ( n -> ... count rem )  begin # dup while repeat ;

: negate  negate ;
: abs  ( n -> |n| )  dup 0 < if negate then ;
: sign  0 < if  [char] - hold  then ;

: space  bl emit ;
: (.)  dup push abs <#  #s pop sign  #> ;
: .  (.) type space ;

: depth  ( -> u )  S0 sp@ - 8 /  2 - ;
: .S  depth S0 16 - swap for  dup @ . 8 -  next drop ;
