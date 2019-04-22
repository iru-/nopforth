1 value RTLD_LAZY

: zlen ( a -> u )   a! 0 begin  b@+  while  drop 1 +  repeat drop ;
: z>s ( a -> a u )   dup zlen ;
: .dlerror ( -> )   dlerror if z>s type exit then drop ;

: load-clib ( a u -> handle )
   s>z RTLD_LAZY dlopen if exit then  .dlerror abort ;

: clib-func ( handle a u -> 'func )
   s>z dlsym if exit then  .dlerror abort ;

: Cfunc>entry ( handle a u -> 'func )
   2dup 2push  clib-func  2pop entry, ;

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
   dup 5 > abort" too many arguments to C function"
   dup 4 > if callC5 then drop
   dup 3 > if callC4 then drop
   dup 2 > if callC3 then drop
   dup 1 > if callC2 then drop
       0 > if callC1 then drop
   pop absjump, ;
forth

( User API )
0 value handle

: library: ( -> )
   handle if dlclose then drop  bl word load-clib to handle ;

: Cfunction: ( #args -> )   handle bl word Cfunc>entry callC, ;
