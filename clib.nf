1 value RTLD_LAZY

: zlen ( a -> u )   a! 0 begin b@+ while 1 + repeat ;
: z>s ( a -> a u )   dup zlen ;

: errorstr ( -> a u )   dlerror dup if z>s exit then drop 0 0 ;
: ?clib-abort ( flag -> )   if errorstr abort then ;

: clib-load ( a u -> handle )
   s>z RTLD_LAZY dlopen dup 0 = ?clib-abort ;

: clib-symbol ( handle a u -> 'func )
   s>z dlsym dup 0 = ?clib-abort ;

: cfunc>entry ( handle a u -> 'func )
   2dup 2push  clib-symbol  2pop entry, ;

hex
: callC5   C08949 3, [compile] drop ;
: callC4   C18948 3, [compile] drop ;
: callC3   C28948 3, [compile] drop ;
: callC2   C68948 3, [compile] drop ;
: callC1   C78948 3, ;

: absjump, ( 'func -> )
   BB48 2, ,  \ mov $'func, %rbx
   E3FF 2, ;  \ jmp *%rbx

: callC, ( #args 'func -> )
   push
   dup 5 > s" too many arguments to C function" ?abort
   dup 4 > if callC5 then
   dup 3 > if callC4 then
   dup 2 > if callC3 then
   dup 1 > if callC2 then
       0 > if callC1 then
   pop absjump, ;
forth

( User API )
0 value handle

: library: ( -> )
   handle if handle dlclose then
   next-word clib-load to handle ;

: Cfunction: ( #args "name" -> )
   handle next-word cfunc>entry callC, ;
