# nop
Nop is a dialect of the Forth programming language. It provides an environment
for the user to interact with and control computers.

It runs on x86_64 CPUs and the following operating systems are supported

 OS              | Build | Boot | Dynamic libraries |
-----------------|-------|------|-------------------|
Linux            | ✓     | ✓    | ✓                 |
FreeBSD          | ✓     | ✓    | ✓                 |
OpenBSD          | ✓     | ✓    | ✓                 |
NetBSD           | ✓     | ✓    | ✓                 |
macOS            | ✓     | ✓    | ✓                 |
Windows (cygwin) | ✓     | ✓    | ❌                |

Support for arm64 is currently a work in progress and runs on macOS on Apple Silicon.


## Preparing nop for use
To run nop, you first need to build it using a straightforward

```
% make
```

(or `gmake` on BSDs).


This will build an executable in `bin/nop` and perform a smoke test of the
bootstraping procedure. In principle, nop can already be used. However, to be
sure the environment is behaving as it should, run the tests:

```
% make test
```

In case a test fails, the whole procedure is aborted and the last line of
output will be similar to

```
make: *** [Makefile:54: test] Error 1
```

If this happens for a supported operating system, please file a bug in
https://github.com/iru-/nopforth/issues. If all tests pass, nop is ready to be
used.

## Basic usage
Nop may be run with or without command line arguments. Without arguments, you
should see

```
% nop
nop forth
ok 
```

The `ok` at the beginning of the line means nop is ready to accept your
commands. It will read and evaluate a line of input at time, and no processing
is done until the line is input. Note that nop will not output any results by
itself, so if you are used to read-eval-print loops (REPL), nop may be seen as
presenting a read-eval-loop. To exit, either run `bye` or use your terminal's
end of transmission control sequence (Control-D on most unix terminals).

If instead of talking to nop directly you want to execute a nop source file,
pass the file as a command line argument:

```
% nop myprogram.ns
```

Nop will execute the file and immediately exit. Note that only the first
argument is taken as a source file, the rest are available for the program to
use. As an example of the latter usage, output this very file with:

```
% nop examples/cat.ns README.md
```

## Further considerations
Now that you know how to talk to nop, it is time to learn how to use the
facilities provided. If you have already used Forth before, you can jump right
to the glossary of words in `doc/glossary.txt`. If you are a newcomer to Forth,
I strongly advise you first learn the basics of the language somewhere else and
then come back as a more experienced forther.

Apart from the glossary, there are some rather incomplete documentation in the
`doc` directory. In `examples` you will find some example nop programs.

For questions, suggestions and discussions, please open issues at
https://github.com/iru-/nopforth/issues.
