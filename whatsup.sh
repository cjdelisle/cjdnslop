#!/bin/sh
die() { echo "Error: $1"; exit 100; }
AFL_DIR=`echo ./afl/afl-2*`
AFL_WHATSUP=`which afl-whatsup 2>/dev/null || echo $AFL_DIR/afl-whatsup`;
[ -f "$AFL_WHATSUP" ] || die "missing afl-whatsup -- did you run ./setup.sh ?"
OUTPUT_DIR="./findings";
$AFL_WHATSUP $OUTPUT_DIR;