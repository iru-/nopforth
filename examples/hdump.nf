0 value r/o
: file-size ( fd -> u )   push 0 2 pop position-file ;
: spaces ( u -> )   for space next ;
: within ( u lo hi -> flag )  push over <=  swap pop <  and ;
: 2dup  over over ;
8 value cell
: min ( a b -> a|b )   2dup > if nip exit then drop ;

: fsize ( a u -> u' )
  r/o open-file  dup file-size  swap close-file abort" can't retrieve file size" ;

0 value /line
variable off

hex
: .off               off @ <# cell for # # next #> type ;
: align ( u -> )     /line swap - 3 * spaces ;
: h. ( u -> )        <# # # #> type space ;
: bytes ( a u -> )   swap a! for b@+ h. next ;
: c. ( c -> )        dup bl 7F within not if drop [char] . then emit ;
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

: open ( a u -> )     r/o open-file dup 0 < abort" can't open file" to fd ;
: position ( u -> )   0 fd position-file 0 < abort" can't position file" ;
: close               fd close-file drop ;
: read ( a -> u )     'buf size fd read-file dup 0 < abort" can't read from file"  dup update ;

: setup  ( a u start end width -> )
  here to 'buf dup allot  to /line  over - remaining !
  push open  pop position  0 off ! hex ;

: (hdump)  ( a u start end width -> )
  setup  begin read dup while 'buf swap line cr repeat
  drop close  /line negate allot ;

: hdumped  ( a u -> )  2dup fsize 0 swap 10 (hdump)  /line negate allot ;
: hdump  bl word hdumped ;

hto 1516
hdump notes.txt
bye
