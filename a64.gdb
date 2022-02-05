# SPDX-License-Identifier: MIT
# Copyright (c) 2018-2022 Iruatã Martins dos Santos Souza

define dstk
  echo T\040\040\040\040
  print/x $x0
  set $p = $x29
  while $p < &dstack0
    x/gx $p
    set $p = $p + 8
  end
end

define rstk
  set $p = $sp
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

define dh
  x/zg $arg0
  x/zg $arg0+8
  x/zb $arg0+16
  set $namelen = (char)*($arg0+16)
  set $i = 0
  while $i < $namelen
    x/c ($arg0+16+1+$i)
    set $i = $i + 1
  end
end

define go
  step
  state
end

break main
run
set $R0 = $sp

