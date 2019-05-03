macro
: \  10 word drop drop ;
: (  41 word drop drop ;

forth
: decimal ( -> )   10 base ! ;
: hex ( -> )       16 base ! ;

: abort0 ( -> )   0 0 abort ;
: cfa ( a -> a' )   >cfa @ ;

( Control flow )
macro hex
: 4! ( n a -> )
   004D8B48 4,           \ mov (%rbp), %rcx
   0889 2,               \ mov %ecx, (%rax)
   086D8D4800458B48 ,    \ mov (%rbp), %rax; lea 8(%rbp), %rbp (aka drop)
   086D8D4800458B48 , ;  \ drop

: then ( a -> )   0 hole !  here  over 4 + -  swap 4! ;

: if0 ( -> a )
   C08548 3,     \ test %rax, %rax
   850F 2,       \ jnz...
   here  0 4, ;  \ ...0

: [compile] ( -> )
   next-word mlatest dfind if0 abort0 then  cfa call, ;

: r@ ( -> )      [compile] dup  24048B48 4, ;  \ mov (%rsp), %rax
: rdrop ( -> )   48 b, 0824648D 4, ;  \ lea 8(%rsp), %rsp

: asave ( -> )   [compile] a    [compile] push ;
: arest ( -> )   [compile] pop  [compile] a! ;

: begin ( -> a )        here ;
: while ( a -> a' a )   [compile] if swap ;
: again ( a -> )        here 5 + -  E9 b, 4, ;
: repeat ( a a' -> )    [compile] again [compile] then ;

: for ( -> a a' )
   [compile] push [compile] begin [compile] r@ [compile] while [compile] drop ;

: next ( a a' -> )
   240CFF48 4,  \ decq (%rsp)
   [compile] repeat [compile] rdrop [compile] drop ;

: 2push ( -> )   [compile] push [compile] push ;
: 2pop ( -> )    [compile] pop [compile] pop ;
: 2dup ( -> )    [compile] over [compile] over ;

: rshift ( n #places -> n' )
   C18948 3,    \ mov %rax, %rcx
   [compile] drop
   E8D348 3, ;  \ shr %cl, %rax

: lshift ( n #places -> n' )
   C18948 3,    \ mov %rax, %rcx
   [compile] drop
   E0D348 3, ;  \ shl %cl, %rax

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
: *      * ;
: /mod   /mod ;
: /      /mod nip ;
: mod    /mod drop ;

: lshift   lshift ;
: rshift   rshift ;

( Dictionary )
forth hex
: find ( a u -> a'|0 )   latest @ dfind ;

: ' ( -> a )   next-word find if0 abort0 then  cfa ;
: f' ( -> a|0 )   next-word flatest @ dfind if0 abort0 then  cfa ;

macro
: ['] ( -> )    '  [compile] lit ;
: [f'] ( -> )   f' [compile] lit ;
forth

: allot ( n -> )   here +  h ! ;

: dovar ( -> n )       pop ;
: created ( a u -> )   entry, ['] dovar call, ;
: create ( -> )        next-word created ;

: variable ( -> )   create 0 , ;

: (value) ( -> n )   pop @ ;
: value ( n -> )     entry ['] (value) call, , ;
: to ( n -> )        ' 5 + ! ;
macro
: to ( n -> )        ' 5 +  [compile] lit  [compile] ! ;
forth


( Memory utilities )
8 value cell

forth
: cells ( -> u )   cell * ;
: advance ( a u n -> a+n u-n )   swap over  - push + pop ;

: move ( src dst u -> )
   push push a! pop pop
   begin while
     over b@+ swap b!
     1 advance
   repeat
   drop drop ;

: +! ( n a -> )   swap over  @ +  swap ! ;
: mem, ( a u -> )   here over allot  swap move ;

: mem= ( a1 a2 u -> f )
   if0  drop drop drop -1 exit  then
   push  over b@ over b@ /= if  drop drop drop rdrop 0 exit then drop
   1 + swap  1 + swap  pop 1 -  mem= ;


( Strings )
forth decimal
: cr ( -> )   10 emit ;
32 value bl

: char ( -> b )     bl word drop b@ ;
macro
: [char] ( -> b )   char [compile] lit ;
forth

: ," ( -> a u )       [char] " word  here swap 2dup 2push  move  2pop ;
: z" ( -> a )         ,"  over +  0 swap b! ;
: s>z ( a u -> a' )   here swap 2dup 2push  move  2pop over +  0 swap b! ;
: zlen ( a -> u )     a! 0 begin b@+ while drop 1 + repeat drop ;
: z>s ( a -> a' u )   dup zlen ;

: ." ( -> )   [char] " word type ;

: s= ( a1 u1 a2 u2 -> f )
   push swap pop over /= if  drop drop drop drop 0 exit  then drop mem= ;

: search ( b a u -> a' u' )
   if0  push nip pop exit  then
   push  over over b@ = if  drop nip pop exit  then drop  pop
   1 advance search ;

: -tail ( b a u -> a u' )   over push search drop pop swap over - ;
: -head ( b a u -> a u' )   search  1 advance ;

macro hex
: slit ( a u -> )
   E9 b, here push  0 4,  \ jmp 0
   dup push  mem,  pop pop dup
   [compile] then  4 + [compile] lit [compile] lit ;

: s" ( -> )   [char] " word  [compile] slit ;
: ." ( -> )   [compile] s" [f'] type call, ;

forth
: ?abort ( flag a u -> )   2push if 2pop abort then  drop rdrop rdrop ;


( Pictured numeric conversion )
macro hex
: negate ( n -> n' )   D8F748 3, ;  \ neg %rax

forth decimal
: digit ( n -> n' )   dup 9 >  7 and +  48 + ;

: hold ( count rem b -> b count+1 rem )   swap push  swap 1 + pop ;

: <# ( n -> 0 n )               0 swap ;
: #  ( n -> ... count rem )     base @ /mod swap digit hold ;
: #> ( ... count rem -> a u )   asave  drop  here a!  dup push for b!+ next  here pop  arest ;
: #s ( n -> ... count rem )     begin # while repeat ;

: negate   negate ;
: abs ( n -> |n| )   dup 0 < if swap negate swap then drop ;
: sign ( n -> )   0 < if  drop [char] - hold exit  then drop ;

: space ( -> )   bl emit ;

: (.) ( n -> )   dup push abs <#  #s pop sign #> ;
: . ( n -> )     (.) type space ;

: depth ( -> u )   S0 sp@ - 8 /  2 - ;
: .S ( -> )   depth S0 16 - swap for  dup @ . 8 -  next drop  s" <- top " type ;


( Files )
forth decimal
: (open-create) ( a u mode syscall# -> fd )   push push s>z pop pop syscall2 ;
: create-file ( a u mode -> fd )   85 (open-create) ;
: open-file ( a u mode -> fd )   2 (open-create) ;

: read ( a u fd -> n )   sysread ;
: read-byte ( fd -> b|-1 )
   push here 1 pop read 1 = if  drop here b@ exit  then drop -1 ;

: read-line ( a u fd -> n )
   push push a! pop pop over  for
     dup read-byte dup b!+
     dup -1 = if  drop drop drop pop - exit  then drop
         10 = if  drop drop pop - 1 + exit  then drop
   next
   drop ;

: write ( a u fd -> n )   syswrite ;
: write-byte ( b fd -> n )   push  here b!  here 1 pop write ;
: write-line ( a u fd -> n )
   dup push write  10 pop write-byte
   1 /= if  drop drop -1 exit  then drop 1 + ;

: close ( fd -> n )   3 syscall1 ;
: position-file ( n ref fd -> n' )   swap push swap pop 8 syscall3 ;
: file-position ( fd -> n' )   push 0 1 pop position-file ;


( File loading )
: input@ ( -> fd buf tot used pos 'refill )
   infd @ inbuf @ intot @ inused @ inpos @ 'refill @ ;

: input! ( fd buf tot used pos 'refill -> )
   'refill ! inpos ! inused ! intot ! inbuf ! infd ! ;

: save-input ( -> )
   pop pop  input@ push push push push push push  push push ;

: restore-input ( -> )
   pop pop  pop pop pop pop pop pop input!  push push ;

: file-refill ( -> n )
   0 inpos !  inbuf @ intot @ infd @ read-line  dup inused ! ;

256 value /buf
create buf /buf allot

: included ( a u -> )
   'prompt @ push  0 'prompt !  save-input
   0 open-file  dup 0 <  s" can't include file" ?abort
   dup buf /buf 0 0 ['] file-refill input!
   push  readloop  pop close drop
   restore-input  pop 'prompt ! ;

: include ( -> )   bl word included ;


( Shell utilities )
: #!  [compile] \ ;

: #args ( -> u )      S0 @ @ ;
: 'arg ( u -> a )     1 + cells  S0 @ + ;
: arg ( u -> a u' )   'arg @ z>s ;
: 'env ( u -> a )     #args 1 + + 'arg @ ;

variable arg-offset
: next-arg ( -> a u )
   arg-offset @  dup #args >= if  drop drop 0 0 exit  then drop
   arg  1 arg-offset +! ;

: env-name ( a -> a u )      [char] = swap z>s -tail ;
: env-value ( a -> a' u' )   [char] = swap z>s -head ;

: (getenv) ( a u env# -> a' u'|0 )
   push  r@ 'env if0  drop drop rdrop 0 exit  then
   push 2dup pop env-name s= if  drop drop drop pop 'env env-value exit  then drop
   pop 1 + (getenv) ;

: getenv ( a u -> a' u'|0 )   0 (getenv) ;

anon:
  #args 1 = if drop banner exit then drop
  2 arg-offset !  1 arg included bye ;
execute
