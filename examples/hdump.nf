#! /usr/bin/env nop

0 value r/o
: file-size ( fd -> u )   push 0 2 pop position-file ;
: spaces ( u -> )   for space next ;
: within ( u lo hi -> flag )  push over <=  swap pop <  and ;
: 2dup  over over ;
8 value cell
: min ( a b -> a|b )   2dup < if drop drop exit then drop nip ;

: fsize ( a u -> u' )
  r/o open-file  dup file-size  swap close-file s" can't retrieve file size" ?abort ;

0 value /line
variable off

hex
: .off ( -> )        off @ <# cell for # # next #> type ;
: align ( u -> )     /line swap - 3 * spaces ;
: h. ( u -> )        <# # # #> type space ;
: bytes ( a u -> )   swap a! for b@+ h. next ;
: c. ( c -> )        dup bl 7F within not if  [char] . nip swap  then drop emit ;
: text ( a u -> )    swap a! for b@+ c. next ;
: line ( a u -> )    .off 2 spaces 2dup bytes dup align 2 spaces text ;
decimal

variable remaining
0 value fd
0 value 'buf 

: size ( -> u )         remaining @ /line min ;
: remaining- ( u -> )   negate remaining +! ;
: off+ ( u -> )         off +! ;
: update ( u -> )       dup remaining- off+ ;

: open ( a u -> )     r/o open-file dup 0 < s" can't open file" ?abort to fd ;
: position ( u -> )   0 fd position-file 0 < s" can't position file" ?abort ;
: close               fd close-file drop ;
: read ( a -> u )     'buf size fd read-file dup 0 < s" can't read from file" ?abort  dup update ;

: setup ( a u start end width -> )
  here to 'buf  dup allot  to /line  over - remaining !
  push open  pop position  0 off ! hex ;

: (hdump) ( a u start end width -> )
  dup push setup
  begin read while  'buf swap line cr  repeat  drop close
  pop negate allot ;

: hdumped ( a u -> )   2dup fsize 0 swap 10 (hdump) ;


anon: begin next-arg while  hdumped repeat drop drop ;  execute
