# SPDX-License-Identifier: MIT
# Copyright (c) 2018-2020 Iruatã Martins dos Santos Souza

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

define go
  step
  state
end

break main
run
set $R0 = $sp

