macro hex
: 1+   C0FF48 3, ;
: 1-   C8FF48 3, ;

forth decimal
: test  0 2147483647 begin 1- swap 1+ swap dup while repeat drop drop ;
test bye
