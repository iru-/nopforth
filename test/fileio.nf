create fname ," test.out" dup allot value #fname

create wbuf ," text file" dup allot  value /wbuf
fname #fname 420 create-file value fd

." write: '"  wbuf /wbuf type  ." ' " 
wbuf /wbuf fd write-line . cr
fd close-file drop

15 value /rbuf  create rbuf /rbuf allot
fname #fname 0 open-file to fd
rbuf /rbuf fd read-line
." read: '"  rbuf over type  ." ' "  . cr
fd close-file drop

bye
