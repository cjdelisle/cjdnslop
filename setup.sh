#!/bin/sh
die() { echo "Error: $1"; exit 100; }

build_afl() {
    echo 'Building AFL'
    which clang >/dev/null || die "requires clang";
    which wget >/dev/null || die "requires wget";
    which tar >/dev/null || die "requires tar";
    llvm-config --version >/dev/null || die "requires llvm development version";

    [ -f afl-latest.tgz ] || wget http://lcamtuf.coredump.cx/afl/releases/afl-latest.tgz || die "wget failed";
    [ -f ./afl-*/afl-fuzz.c ] || tar -zxvf afl-latest.tgz || die "tar -zxvf afl-latest.tgz failed";

    cd afl-* || die "cd afl-*";

    if test "x$PATCH_AFL" = "x1" && ! test -f ./PATCHED ; then
        echo 'Applying patches to afl'
        ls ../patches/*.patch | while read x; do
            echo "Applying $x"
            patch -p0 < $x || die "failed patch";
        done
        echo '' > ./PATCHED
    fi

    export AFL_DIR=`pwd`;
    [ -f ./afl-fuzz ] || make || die "failed to compile afl";
    cd llvm_mode || die "cd llvm_mode";
    [ -f ../afl-clang-fast ] && echo 'afl clang fast found';
    if ! test -f ../afl-clang-fast -a -f ./test-insn; then
        rm ../afl-clang-fast 2>/dev/null
        make SHELL='sh -x' || die "failed to compile afl-clang-fast"
    fi
    cd ../../ || die "cd ../../";
    export AFL_CLANG_FAST=$AFL_DIR/afl-clang-fast;
    return 0;
}

use_system_afl() {
    export AFL_CLANG_FAST=`which afl-clang-fast`;
    return 0;
}

which git >/dev/null || die "requires git";
which make >/dev/null || die "requires make";
if which afl-clang-fast >/dev/null 2>/dev/null && which afl-fuzz >/dev/null 2>/dev/null; then
    use_system_afl;
else
    build_afl;
fi

[ -d cjdns ] || git clone git://github.com/cjdelisle/cjdns.git || die "failed to clone cjdns";
cd cjdns || die "cd cjdns";
git checkout crashey || die "checkout crashey";

./do || die "Failed to compile cjdns without afl";
CC=$AFL_CLANG_FAST ./do || die "Failed to compile cjdns with afl";

echo "Cjdns compiled for AFL, run fuzz.sh to begin fuzzing";