# SPDX-License-Identifier: MIT
# Copyright (c) 2018-2020 Iruatã Martins dos Santos Souza

define dstk
  echo T\040\040\040\040
  print/x $rax
  set $p = $rbp
  while $p < &dstack0
    x/gx $p
    set $p = $p + 8
  end    
end

define rstk
  set $p = $rsp
  while $p < $R0
    x/gx $p
    set $p = $p + 8
  end
end

define state
  dstk
  echo \n
  rstk
end

define instate
  echo inpos\040\040
  print/x (short)inpos
  echo inbuflen\040\040
  print/x (short)inbuflen
end

define dh
  x/gx $arg0
  x/gx $arg0+8
  x/bx $arg0+16
  set $namelen = (char)*($arg0+16)
  set $i = 0
  while $i < $namelen
    x/c ($arg0+16+1+$i)
    set $i = $i + 1
  end
end

define ddict
  set $word = $arg0
  while $word != 0
    dh $word
    set $word = *$word
  end
end

define findcfa
  set $word = $arg1
  while $word != 0
    set $cfa = $word+8
    if *$cfa == $arg0
       dh $word
       loop_break
    end
    set $word = *$word
  end
end

document dh
Dump a header starting at address given as first argument
end

define go
  step
  state
end

break main
run
set $R0 = $rsp

