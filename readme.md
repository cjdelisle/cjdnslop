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

When `./whatsup.sh` shows that some crashes have happened, you can quickly attempt to reproduce
them using using `./debug_crashes.sh`. It will quickly run each test in gdb and will automatically
exit and proceed to the next test if the current one exits without a crash. Unfortunately, cjdns
does not execute exactly determinently, one major offender is the clock time which affects when
certain internal events will trigger, thus crashes do not always reproduce. If `./debug_crashes.sh`
returns to a shell then none of the crashes were reproducable, if it stops in gdb then you have a
reproducible crash.

There is also a file called  `./errout.txt`, this is the output from stderr from running the
fuzzer, if there are any assertion failures, the failed assertion should appear in this file.
Sometimes even with crashes which cannot be reproduced, knowing what assertion was triggered will
lead to detecting the cause.

## Reporting

If you find a crash bug, please write to me cjd@cjdns.fr and we can get it fixed quickly. Thank
you for your participation!