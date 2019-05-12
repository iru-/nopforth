#! /usr/bin/env nop
\
\ An implementation of the unix tool cat(1)
\

8192 value /buf
create buf /buf allot

: cat ( fd -> )
   push buf dup /buf r@ read
   dup 1 < if  drop drop drop rdrop exit  then drop type pop cat ;

: cat-stdin ( -> )   0 cat ;

: cat-args ( -> )
   begin next-arg while
      0 open-file  dup 0 < s" can't open file" ?abort cat
   repeat
   drop drop ;

anon:
   #args 3 < if drop cat-stdin exit then  drop cat-args ;
execute


