# CjdnsLop

Fuzzy long-eared cjdns test runner.

[![Build Status](https://travis-ci.org/cjdelisle/cjdnslop.svg?branch=master)](https://travis-ci.org/cjdelisle/cjdnslop)

![fuzzy lop (rabbit breed)](https://raw.githubusercontent.com/cjdelisle/cjdnslop/master/fuzzy_lop.jpg)

Cjdns tests are designed to work well with [American Fuzzy Lop](http://lcamtuf.coredump.cx/afl/)
fuzz tester. You can try testing cjdns with the fuzz tester by using the code in the repository.

## Setup

In order to run these tools, you'll need:

* llvm-dev
* clang
* make
* git
* tar
* wget

and then you'll need to invoke setup.sh

### debian/ubuntu

    sudo apt install llvm-5.0-dev clang-5.0
    export PATH=/usr/lib/llvm-5.0/bin/:$PATH;
    CC=clang CXX=clang++ ./setup.sh

### fedora

    sudo dnf install clang-devel
    CC=clang CXX=clang++ ./setup.sh

## Fuzzing

After setup completes successfully, you can run `./fuzz.sh`. If you set the environment parameter
`JOBS` then it will use that number of fuzzers (for example `JOBS=7 ./fuzz.sh`), otherwise it
will run as many jobs as you have CPU cores. To stop the fuzzers, use `./stop.sh` and to check the
current status, you can use `./whatsup.sh`.

## Debugging

For reasons that are unclear as of the time of this writing, fuzzing cjdns creates quite a lot
of false positives / non-reporducible crashes. You can sift through these looking for any which
are valid using `./debug_crashes.sh`. It will quickly run each test in gdb and will automatically
exit and proceed to the next test if the current one exits without a crash. If this returns to
a shell then all of the issues are "false positives", if this is stopped in gdb then it is a
reproducible crash.

## Reporting

If you find a crash bug, please write to me cjd@cjdns.fr and we can get it fixed quickly. Thank
you for your participation!

## Miscellaneous

A file will be created called `./errout.txt`, this is the output from stderr from running the
fuzzer, if there are any assertion failures, the assertion should appear in this file.