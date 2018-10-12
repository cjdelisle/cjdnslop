#!/bin/sh
die() { echo "Error: $1"; exit 100; }

which wget >/dev/null || die "requires wget";
which tar >/dev/null || die "requires tar";
which git >/dev/null || die "requires git";
which clang >/dev/null || die "requires clang";
which make >/dev/null || die "requires make";
llvm-config --version >/dev/null || die "requires llvm development version";

[ -f afl-latest.tgz ] || wget http://lcamtuf.coredump.cx/afl/releases/afl-latest.tgz || die "wget failed";
[ -f ./afl-*/afl-fuzz.c ] || tar -zxvf afl-latest.tgz || die "tar -zxvf afl-latest.tgz failed";

cd afl-* || die "cd afl-*";
export AFL_DIR=`pwd`;
[ -f ./afl-fuzz ] || make || die "failed to compile afl";
cd llvm_mode || die "cd llvm_mode";
[ -f ../afl-clang-fast ] || make || die "failed to compile afl-clang-fast";
cd ../../ || die "cd ../../";

[ -d cjdns ] || git clone git://github.com/cjdelisle/cjdns.git || die "failed to clone cjdns";
cd cjdns || die "cd cjdns";
git checkout crashey || die "checkout crashey";

./do || die "Failed to compile cjdns without afl";
CC=$AFL_DIR/afl-clang-fast ./do || die "Failed to compile cjdns with afl";

echo "Cjdns compiled for AFL, run fuzz.sh to begin fuzzing";