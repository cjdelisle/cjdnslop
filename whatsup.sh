#!/bin/sh
die() { echo "Error: $1"; exit 100; }
AFL_WHATSUP=`which afl-whatsup || ./afl-*/afl-whatsup` 2>/dev/null;
[ -e $AFL_WHATSUP ] || die "missing afl-whatsup -- did you run ./setup.sh ?"
OUTPUT_DIR="./findings";
$AFL_WHATSUP $OUTPUT_DIR;