macro
: \  refill drop ;
: (  41 word drop drop ;

: decimal ( -> )   10 base ! ;
: hex ( -> )       16 base ! ;


( Control flow )
macro hex
: then ( a -> )   0 hole !  here  over 1 + -  swap b! ;

: [compile] ( -> )
   20 word mlatest dfind dup 0 = if abort then  >cfa @ call, ;

: r@ ( -> )      [compile] dup  24048B48 4, ;  \ mov (%rsp), %rax
: rdrop ( -> )   48 b, 0824648D 4, ;  \ lea 8(%rsp), %rsp

: asave ( -> )   [compile] a    [compile] push ;
: arest ( -> )   [compile] pop  [compile] a! ;

: begin ( -> a )        here ;
: while ( a -> a' a )   [compile] if swap ;
: again ( a -> )        here 5 + -  E9 b, 4, ;
: repeat ( a a' -> )    [compile] again [compile] then ;

: for ( -> a a' )
   [compile] push [compile] begin [compile] r@ [compile] while ;

: next ( a a' -> )
   240CFF48 4,  \ decq (%rsp)
   [compile] repeat [compile] rdrop ;


( macro -> forth )
\ We define forth words using the macros, so they can be used interactively
forth
: dup    dup ;
: drop   drop ;
: swap   swap ;
: over   over ;
: nip    nip ;

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

: +      + ;
: -      - ;
: /mod   /mod ;
: /      /mod nip ;
: mod    /mod drop ;


( Dictionary )
forth hex
: found ( a u -> a'|0 )   latest dfind ;
: find ( -> a )           20 word found ;
: ' ( -> a|0 )            find dup 0 = if abort then >cfa @ ;

: f' ( -> a|0 )
   flatest push 20 word pop dfind dup 0 = if abort then >cfa @ ;

macro
: ['] ( -> )   '  [compile] lit ;
: [f'] ( -> )   f' [compile] lit ;
forth

: allot ( n -> )   here +  h ! ;

: dovar ( -> n )       pop ;
: created ( a u -> )   entry, ['] dovar call, ;
: create ( -> )        20 word created ;

: variable ( -> )   create 0 , ;

: (value) ( -> n )   pop @ ;
: value ( n -> )     entry ['] (value) call, , ;
: to ( n -> )        ' 5 + ! ;
macro
: to ( n -> )        ' 5 +  [compile] lit  [compile] ! ;
forth


( Memory utilities )
forth
: advance ( a u n -> a+n u-n )   swap over  - push + pop ;

: move ( src dst u -> )
   push push a! pop pop
   begin dup while
     over b@+ swap b!
     1 advance
   repeat
   drop drop ;

: +! ( n a -> )   swap over  @ +  swap ! ;
: mem, ( a u -> )   here over allot  swap move ;


( Strings )
forth decimal
: cr ( -> )   10 emit ;
32 value bl

: char ( -> b )     bl word drop b@ ;
macro
: [char] ( -> b )   bl word drop b@ [compile] lit ;
forth

: ," ( -> u )      [char] " word  dup push  here swap move  pop ;
: z" ( -> u )      ,"  0 over here + b!  1 + ;
: s>z ( a u -> )   dup push  here swap move  0 here pop + b! ;

: ." ( -> )   [char] " word type ;

macro hex
: slit ( a u -> )   \ u is limited to 127 bytes because of the jump
   EB b, 0 b,  here push dup push  mem,  pop pop dup 1 -
   [compile] then [compile] lit [compile] lit ;

: s" ( a u -> )   [char] " word  [compile] slit ;

: abort" ( t -> )
   [compile] s" [compile] push [compile] push
   [compile] if
      [compile] pop [compile] pop
      [f'] type call, [f'] abort call,
      [compile] exit
   [compile] then
   [compile] rdrop [compile] rdrop ;
forth


( Pictured numeric conversion )
macro hex
: negate ( n -> n' )   D8F748 3, ;  \ neg %rax

forth decimal
: digit ( n -> n' )   dup 9 >  7 and +  48 + ;

: hold ( count rem b -> b count+1 rem )   swap push  swap 1 + pop ;

: <# ( n -> 0 n )               0 swap ;
: #  ( n -> ... count rem )     base @ /mod swap digit hold ;
: #> ( ... count rem -> a u )   asave  drop  here a!  dup push for b!+ next  here pop  arest ;
: #s ( n -> ... count rem )     begin # dup while repeat ;

: negate   negate ;
: abs ( n -> |n| )   dup 0 < if negate then ;
: sign ( n -> )   0 < if  [char] - hold  then ;

: space ( -> )   bl emit ;

: (.) ( n -> )   dup push abs <#  #s pop sign  #> ;
: . ( n -> )     (.) type space ;

: depth ( -> u )   S0 sp@ - 8 /  2 - ;
: .S ( -> )   depth S0 16 - swap for  dup @ . 8 -  next drop  s" <- top " type ;


( Files )
forth decimal
: (open-create) ( a u mode n# -> fd )   push push s>z here pop pop syscall2 ;
: create-file ( a u mode -> fd )   85 (open-create) ;
: open-file ( a u mode -> fd )   2 (open-create) ;

: read-file ( a u fd -> u )   sysread ;
: read-byte ( fd -> b|-1 )
   push here 1 pop read-file 1 = if here b@ exit then -1 ;

: eol? ( b -> t )   dup -1 =  swap 10 =  or ;
: read-line ( a u fd -> n )
   push push a! pop pop over
   for
     dup read-byte dup eol? if  drop drop pop - exit  then
     b!+
   next
   drop ;

: write-file ( a u fd -> u )   syswrite ;
: write-byte ( b fd -> n )   push  here b!  here 1 pop write-file ;
: write-line ( a u fd -> n )
   dup push write-file  10 pop write-byte -1 = if drop -1 exit then  1 + ;

: close-file ( fd -> u )   3 syscall1 ;
: position-file ( n rel? fd -> n' )   swap push swap pop 8 syscall3 ;
: file-position ( fd -> n' )   push 0 1 pop position-file ;


( File loading )
: input@ ( -> fd buf tot used pos )
   infd @ inbuf @ intot @ inused @ inpos @ ;

: input! ( fd buf tot used pos -> )
   inpos ! inused ! intot ! inbuf ! infd ! ;


256 value /buf
create   buf  /buf allot
variable fd

: included ( a u -> )
   input@ push push push push push
   0 open-file dup 0 < if abort then
   dup buf /buf 0 0 input!
   push  readloop  pop close-file drop
   pop pop pop pop pop input! ;

: include ( -> )   bl word included ;


