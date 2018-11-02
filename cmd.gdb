define dstk
  echo T\040\040\040\040
  print/z $rax
  set $p = $rbp
  while $p < &dstack0
    x/gx $p
    set $p = $p + 8
  end    
end

define rstk
  set $p = $rsp
  while $p <= $R0
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
  print/z (short)inpos
  echo inbuflen\040\040
  print/z (short)inbuflen
end

define dh
  x/zg $arg0
  x/zb $arg0+8
  set $namelen = (char)*($arg0+8)
  set $i = 0
  while $i < $namelen
    x/c ($arg0+8+1+$i)
    set $i = $i + 1
  end
  x/zg $arg0+8+1+$namelen
end

document dh
Dump a header starting at address given as first argument
end

define go
  step
  state
end

break boot
run
set $R0 = $rsp

