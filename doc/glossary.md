## Stack manipulation
```dup``` ```n -> n n```  _macro+forth_

  Duplicate top element

```drop``` ```n ->``` _macro+forth_

  Remove top element

```swap``` ```m n -> n m``` _macro+forth_

  Swap top and second elements

```over``` ```m n -> m n m``` _macro+forth_

  Copy second element to top

```nip``` ```m n -> n``` _macro+forth_

  Remove second element

```push``` ```n ->``` ```r:-> n``` _macro_

  Push top of data stack to return stack

```pop``` ```r:n ->``` ```-> n``` _macro_

  Pop top of return stack to data stack

```r@``` ```r:n -> n``` ```-> n``` _macro_

  Copy top of return stack to data stack

```rdrop``` ```r:n ->``` _macro_

  Drop top of return stack

```rdec``` ```r:n -> n-1``` _macro_

  Decrement top of return stack

```2dup``` ```m n -> m n m n``` _macro+forth_

  Duplicate top two elements

```2push``` ```m n ->``` ```r:-> m n``` _macro_

  Push top two elements of data stack to return stack

```2pop``` ```r:m n ->``` ```-> m n``` _macro_

  Pop top two return stack elements to data stack

```tuck``` ```m n -> n m n```

  Insert top element in third place

```S0```  _variable_

  Bottom of data stack

```sp@``` ```-> a```

  Return the address of the top of the data stack

```depth``` ```-> u```

  Return current data stack depth

```.S``` ```... -> ...```

  Output data stack contents with top as the rightmost element


## Operating System interface
```sysread read``` ```a u fh -> u'```

  Read at most `u` bytes from file handler `fh` into address `a`.
  Return number of bytes read.

```syswrite write``` ```a u fh -> u'```

  Write `u` bytes starting at address `a` to file handler `fh`.
  Return number of bytes written.

```sysexit``` ```n ->```

  Exit process with status `n`

```open-file``` ```a u flags mode -> fh```

  Open file named by the string `a u` in `mode` with `flags`.
  Return file handle.

```create-file``` ```a u mode -> fh```

  Create file named by the string `a u` and open it in the given `mode`.
  Return file handle.

```close``` ```fh -> err```

  Close file handle `fh`.
  Return error code, 0 on success.

```position-file``` ```n ref fh -> n'```

  Position file to position `n`.
  Check OS manuals for the meaning of `ref` and the return value.

```file-position``` ```fh -> u```

  Convert file handler to its current file position

```fsize``` ```fh -> u```

  Convert file handler to file size

```sysmmap``` ```addr length prot flags fh offset -> addr'```

  Map file to memory.
  Check OS manuals for the meaning of arguments and return value.

```fmap``` ```fh -> a u```

  Map file to memory.
  Return buffer to mapped file.

```sysmunmap``` ```a u -> err```

  Unmap file from memory.
  Check OS manuals for the meaning of arguments and return value.

```syscall1``` ```n1 syscall# -> nr```

```syscall2``` ```n1 n2 syscall# -> nr```

```syscall3``` ```n1 n2 n3 syscall# -> nr```

```syscall4``` ```n1 n2 n3 n4 syscall# -> nr```

```syscall5``` ```n1 n2 n3 n4 n5 syscall# -> nr```

```syscall6``` ```n1 n2 n3 n4 n5 n6 syscall# -> nr```

  Call system call with given arguments.
  Return system call status.

```dlopen dlsym dlerror dlclose```

  Check your OS manuals for their description and usage

```#!```

  Same as `\`

```#args```

  Number of command line arguments

```arg``` ```u -> a u'```

  Return buffer of command line argument `u`

```next-arg``` ```-> a u```

  Return buffer of next unprocessed command line argument

```getenv``` ```a -> a'```

  Convert environment variable named by string `a` to its value represented by
  string `a'`


## I/O
```expect``` ```a u -> u'```

  Read at most `u` bytes from the current input into address `a`.
  Return number of bytes read.

```type``` ```a u ->```

  Write `u` bytes from address `a` to the current output

```emit``` ```b ->```

  Write byte to the current output

```'key```  _variable_

  Address of the current key routine

```key``` ```-> b```

  Read byte from the current input.
  Return byte on success, -1 on failure.

```read-byte``` ```fh -> b```

  Read byte from file.
  Return byte on success, -1 on failure.

```read-line``` ```a u fh -> n```

  Read at most `u` bytes from file into address `a`.
  Return number of bytes read.
  Check OS manuals for the meaning of the failure return values.

```write-byte``` ```b fh -> n```

  Write byte to file.
  Return 1 on success.
  Check OS manuals for the meaning of the failure return values.

```write-line``` ```a u fh -> n```

  Write buffer followed by a newline to file.
  Return number of bytes written on success.
  Check OS manuals for the meaning of the failure return values.

```reset-input```

  Reset current input state

```refill``` ```-> u```

  Refill current input.
  Return `u > 0` if refilled, `u <= 0` otherwise.

```infd```  _variable_

  File descriptor feeding the input

```inbuf```  _variable_

  Pointer to input buffer

```intot```  _variable_

  Total number of bytes in input buffer

```inused```  _variable_

  Number of filled bytes in input buffer

```inpos```  _variable_

  Input buffer position

```source ``` ```-> a u```

  Return a string describing the part of the input buffer yet to be processed

```cr```

  Emit ASCII newline

```space```

  Emit ASCII space

```spaces``` ```n ->```

  Emit `n` ASCII spaces

```printable?``` ```b -> flag```

  Substitute byte by true if it is a printable ASCII character, by false
  otherwise

```char``` ```-> n``` _consumes input_

  Return ASCII code of next input letter

```[char]```  _macro_  _consumes input_

  Compile literal ASCII code of the next input letter

```(.)``` ```n ->```

  Output number

```.``` ```n ->```

  Output number and space

```.addr``` ```a ->```

  Output address in hex and zero-filled to the left

```hb.``` ```b ->```

  Output byte in hex

```bytes``` ```a u ->```

  Output bytes of buffer in hex, separated by spaces

```c.``` ```b ->```

  Output byte if it is printable, dot otherwise

```text``` ```a u ->```

  Output printable bytes of buffer as is; as dots if non-printable

```dump``` ```a u ->```

  Dump buffer

```'rel```  _variable_

  Address of read-eval loop routine

```rel```

  Read-eval loop

```'warm```  _variable_

  Address of warm boot routine

```warm```

  Warm boot

```abort``` ```str ->```

  Output string if its non-zero, reset input and stacks and warm boot

```?abort``` ```flag str ->```

  Abort if `flag` is non-zero

```?underflow```

  Abort on data stack underflow

```evaluate``` ```-> ...```

  Interpret or compile input buffer

```'refill```  _variable_

  Address of input refill routine

```refill```

  Refill input buffer

```refilled?``` ```-> flag```

  Return true if the current input state lead to a refill, false otherwise

```included``` ```a u ->```

  Load and evaluate file named by buffer

```include```  _consumes input_

  Same as included with file named by the remaining line of input


## Memory
```cell```  _value_

  Number of bytes of memory cell

```@``` ```a -> n``` _macro+forth_

  Fetch cell from address `a`

```b@``` ```a -> b``` _macro+forth_

  Fetch byte from address `a`

```!``` ```n a ->``` _macro+forth_

  Store n at address `a`

```b!``` ```b a ->``` _macro+forth_

  Store byte `b` at address `a`

```4!``` ```n a ->``` _macro_

  Store half-cell `n` at address `a`

```a``` ```-> n``` _macro+forth_

  Return contents of register `a`

```a!``` ```n ->``` _macro+forth_

  Store n into register `a`

```@+``` ```-> n``` _macro+forth_

  Fetch cell from address in register `a`. Increment a by cell.

```b@+``` ```-> b``` _macro+forth_

  Fetch byte from address in register `a`. Increment a by 1.

```!+``` ```n ->``` _macro+forth_

  Store n into address in register `a`. Increment a by cell.

```b!+``` ```b ->``` _macro+forth_

  Store byte into address in register `a`. Increment a by 1.

```move``` ```src dst u ->```

  Copy `u` bytes from `src` to `dst`

```cells``` ```n -> n'```

  Convert number of cells to number of bytes

```advance``` ```a u n -> a+n u-n```

  Advance buffer by `n` bytes

```mem,``` ```a u ->```

  Write buffer to the dictionary

```mem=``` ```a1 u1 a2 u2 -> flag```

  Substitute two buffer by true if their contents are equal, by false otherwise

```search``` ```a u b -> a' u'```

  Same as scan

```skip``` ```a u b -> a' u'```

  Skip sequence of byte `b` in buffer `a u`.
  Return the remaining buffer after the sequence.

```scan``` ```a u b -> a' u'```

  Scan buffer `a u` for byte `b`.
  Return the remaining buffer, starting at the first `b`. If `b` was not found,
  the top of the stack is zero.

```number``` ```a u -> n err```

  Convert buffer `a u` to a number. If the first byte is $, the rest is treated
  as a positive hex number. Otherwise, it is a decimal number.
  Return converted number and error, which is zero on success.

```head``` ```a u b -> a' u'```

  Scan buffer `a u` and return the buffer up to the last byte before delimiter `b`

```tail``` ```a u b -> a' u'```

  Scan buffer `a u` and return the buffer after delimiter `b`


## Strings
```base```  _variable_

  Number base for number output

```infd```  _variable_

  Input file descriptor

```inbuf```  _variable_

  Input buffer

```intot```  _variable_

  Total length of input buffer

```inused```  _variable_

  Used length in input buffer

```inpos```  _variable_

  Position in input buffer

```source``` ```-> a u```

  Return the unprocessed part of input buffer

```word``` ```b -> a u``` _consumes input_

  Skip a sequence of the delimiter byte b in the input buffer.
  Return buffer from the first byte after the sequence upto the next delimiter.

```next-word``` ```-> a u``` _consumes input_

  Return next word from input buffer. A word is any sequence of non-whitespace
  bytes.

```str-len``` ```a -> a'```

  Convert string address to address of its length

```str-data``` ```a -> a'```

  Convert string address to address of its data

```/str```  _value_

  Size of a string record

```str!``` ```a u dst ->```

  Write string representation for buffer `a u` in `dst`. The contents are not
  copied.

```str>mem``` ```a -> a' u```

  Convert string to its buffer representation

```str,``` ```a u ->```

  Write string representation and contents of buffer `a u` to the dictionary

```str-len=``` ```a a' -> flag```

  Substitute two strings by true if they have equal lengths, by false otherwise

```str=``` ```a a' -> flag```

  Substitute two strings by true if their contents are equal, by false
  otherwise

```str-size``` ```a -> u```

  Convert string by its total size in memory (contents + string record)

```str-copy``` ```src dst ->```

  Copy `src` string contents to `dst`. Note that the destination will be
  a different string with the same contents.

```str-concat``` ```src dst ->```

  Concatenate source string contents to destination string. The user is
  responsible to guaranteeing there ir enough space for the operation.

```"``` ```-> a``` _macro+forth_  _consumes input_

  Return address of string ended by next " in input

```."```  _macro+forth_  _consumes input_

  Output string ended by next " in input

```print``` ```a ->```

  Output string

```println``` ```a ->```

  Output string as a line

```s>z``` ```a u -> a'```

  Convert buffer to a nul-terminated string. The contents are copied to
  destination.

```zlen``` ```a -> u```

  Convert nul-terminated string to its length

```z"```  _consumes input_

  Return address of nul-terminated string ended by next " in input

```z>mem``` ```a -> a u```

  Convert nul-terminated string to its buffer representation

```<#``` ```n -> 0 n```

  Expect a number on the stack to start pictured numeric conversion

```#>``` ```... -> a u```

  End pictured numeric conversion and return the resulting buffer

```hold``` ```b ->```

  Add byte to picture

```#``` ```n -> ...```

  Add next digit to picture

```#s``` ```n -> ...```

  Add remaining digits to picture

```sign``` ```n ->```

  If number is negative, add its sign to picture

```abs``` ```n -> |n|```

  Convert number to its absolute value


## Dictionary
The current dictionary is where definitions are compiled

```flatest``` ```-> a```

  Return address of latest word defined in the forth dictionary

```mlatest``` ```-> a```

  Return address of latest word defined in the macro dictionary

```latest``` ```-> a```

  Return the address of latest word defined in the current dictionary

```macro```

  Set macro as the current dictionary

```forth```

  Set forth as the current dictionary

```,``` ```n ->```

  Store cell-sized number in dictionary

```2,``` ```n ->```

  Store two-byte number in the dictionary

```3,``` ```n ->```

  Store three-byte number in the dictionary

```4,``` ```n ->```

  Store four-byte number in the dictionary

```b,``` ```b ->```

  Store byte in dictionary

```entry,``` ```a u -> a'```

  Create empty dictionary entry named by `a u`.
  Return address of entry.

```entry```  _consumes input_

  Same as `entry` with name in the next input word

```created``` ```a u ->```

  Create definition named by `a u`. When executed, returns the next dictionary
  address available at the time of its creation.

```create```  _consumes input_

  Same as `created` with name in the next input word

```_variable_```  _consumes input_

  Create variable named by the next input word

```value```  _consumes input_

  Create value named by the next input word

```dfind``` ```a u d -> a'```

  Search entry named `a u` in dictionary at address `d`.
  If found, return the entry's address. If not, return 0.

```find``` ```-> a``` _consumes input_

  Same as `dfind` using the current dictionary

```?find``` ```-> a``` _consumes input_

  Same as `find` but aborting when definition is not found

*\`* _macro_  _consumes input_

  Compile macro named by the next input word

```'``` ```-> a``` _consumes input_

  Search entry named by the next input word in the current dictionary.
  If found, return the entry's code address as literal. If not, abort.

```f'``` ```-> a``` _consumes input_

  Same as `'` but using the forth dictionary

```[']```  _macro_  _consumes input_

  Search entry named by the next input word in the current dictionary.
  If found, compile the entry's code address as literal. If not, abort.

```[f']```  _macro_  _consumes input_

  Same as `[']` but using forth dictionary

```does>``` ```a ->``` _macro_

  Mark start of runtime behavior for a defining word

```to``` ```n ->``` macro+forth  _consumes input_

  Store n to the value named by the next input word

```>cfa``` ```a -> a'```

  Convert entry address to its code field address (CFA)

```cfa``` ```a -> a'```

  Convert entry address to its code address

```pfa``` ```a -> a'```

  Convert entry address to its parameter field address (PFA)

```h```  _variable_

  Dictionary pointer

```here``` ```-> a```

  Return next available address in dictionary

```allot``` ```n ->```

  Advance dictionary pointer by `n`

```call!``` ```'code dst ->```

  Store call to address `'code` in `dst`

```call,``` ```a ->```

  Compile call to address `a` in dictionary

```]```  _macro_

  Switch to compilation mode

```[```  _macro_

  Switch to interpretation mode

```:```  _macro_  _consumes input_

  Create definition named by the next input word

```anon:``` ```-> a``` _consumes input_

  Create anonymous/headless definition.
  Return address of the definition.

```exit```  _macro_

  Exit/return from definition

```;```  _macro_

  Compile exit and switch to execution mode

```lit``` ```n ->``` _macro_

  Compile `n` as a literal to be pushed at runtime

```marker```  _consumes input_

  Create marker named by the next input word. When executed, the marker will
  restore the dictionary to the state before the marker was created.

```empty```

  Restore state of dictionary at boot

```record:```

  Start record definition

```field:``` ```offset size alignment -> offset'``` _consumes input_

  Define record field named by the next input word, at given `offset`, with
  given `size` and `alignment`

```bl```  _value_

  ASCII code for space character


## Intepreter
```'abort``` _variable_

  Address of abort routine

```abort```

  Run abort routine. By default, reset data and return stacks and jump to the
  interpreter loop.

```eval``` ```a u -> ...```

  Evaluate source code in buffer a u.
  When interpreting:
  1. Search the word in the forth dictionary
  2. If found, execute it
  3. If not, search in the macro dictionary
  4. If found, execute it
  5. If not, convert to number
  6. If conversion succeeded, push number to stack
  7. If not, abort

  When compiling:
  1. Search the word in the macro dictionary
  2. If found, execute it
  3. If not, search in the forth dictionary
  4. If found, compile it
  5. If not, convert to number
  6. If conversion succeeded, compile literal
  7. If not, abort

  The itens left on the stack are the results from the evaluation.

```execute``` ```a -> ...```

  Jump to word at address `a`


## Arithmetic
```+``` ```m n -> m+n``` _macro+forth_

  Substitute top two elements by their sum

```-``` ```m n -> m-n``` _macro+forth_

  Substitute top two elements by their difference

```*``` ```m n -> m*n``` _macro+forth_

  Substitute top two elements by their product

```/``` ```m n -> m/n``` forth```

  Substitute top two elements by their quotient

```mod``` ```m n -> remainder(m,n)``` forth```

  Substitute top two elements by the remainder of their division

```/mod``` ```m n -> remainder(m,n) m/n``` _macro+forth_

  Substitute top two elements by their remainder and quotient, respectively

```negate``` ```n -> -n``` _macro+forth_

  Invert sign of top element


## Logic
```true``` ```-> flag```

  Proper true value

```false``` ```-> flag```

  Proper false value

```=``` ```m n -> flag``` _macro+forth_

  Substitute top two elements by true if they are equal, by false otherwise

```~=``` ```m n -> flag``` _macro+forth_

  Substitute top two elements by true if they are different, by false otherwise

```<``` ```m n -> flag``` _macro+forth_

  Substitute top two elements by true if the first is less than the second, by
  false otherwise

```>``` ```m n -> flag``` _macro+forth_

  Substitute top two elements by true if the first is greater than the second,
  by false otherwise

```<=``` ```m n -> flag``` _macro+forth_

  Substitute top two elements by true if the first is less than or equal to the
  second, by false otherwise

```>=``` ```m n -> flag``` _macro+forth_

  Substitute top two elements by true if the first is greater than or equal to
  the second, by false otherwise

```not``` ```n -> ~n``` _macro+forth_

  Substitute top element by true if its false, by false if its true

```within``` ```n lo hi -> flag```

  Substitute top three elments by true if `lo <= n < hi`, by false otherwise

```min``` ```m n -> min(m,n)```

  Substitute top two elements by the lesser of the two


## Bitwise operations
```lshift``` ```n m -> n'``` _macro+forth_

  Substitute top two elements by n shifted m places to the left

```rshift``` ```n m -> n'``` _macro+forth_

  Substitute top two elements by n shifted m places to the right

```and``` ```m n -> AND(m,n)``` _macro+forth_

  Substitute top two elements by their bitwise AND

```or``` ```m n -> OR(m,n)``` _macro+forth_

  Substitute top two elements by their bitwise OR

```xor``` ```m n -> XOR(m,n)``` _macro+forth_

  Substitute top two elements by their bitwise XOR

```~``` ```m -> NOT(n)``` _macro+forth_

  Substitute top element by its bitwise negation


## Miscellaneous
```banner```

  Output nop banner

```hex```

  Set base to 16

```decimal```

  Set base to 10

```bye```

  Exit with zero status

```\```  _macro_  _consumes input_

  Comment remainder of current line

```(```  _macro_  _consumes input_

  Comment until closing parenthesis

```align``` ```a u -> a'```

  Starting from `a`, return next `u`-byte aligned address

```aligned``` ```a -> a'```

  Starting from `a`, return next 8-byte aligned address

```Br```

  Trap into debugger. x86_64 int3 instruction.


## Conditionals
```if``` ```n ->``` _macro_

  Branch if `n` is zero, continue otherwise; drop `n` either way

```then```  _macro_

  Mark the end of an if conditional

```begin```  _macro_

  Begin indefinite loop

```while``` ```n ->``` _macro_

  Stop loop if `n` is zero, continue otherwise; drop `n` either way

```again```  _macro_

  Branch back to begin of indefinite loop

```repeat```  _macro_

  Branch back to begin of `begin-while` loop

```for``` ```n ->``` _macro_

  Begin definite countdown loop of `n` steps

```next```  _macro_

  Finish a for-loop
