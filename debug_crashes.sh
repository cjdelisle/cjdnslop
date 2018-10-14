#!/bin/sh
CJDNS_DIR=`echo ./cjdns/build_*`;
for x in `ls ./findings/`; do
    for y in `ls ./findings/$x/crashes`; do
	echo "Trying out: ./findings/$x/crashes/$y";
	gdb $CJDNS_DIR/test_testcjdroute_c \
            -ex 'set confirm on' \
            -ex "r fuzz --quiet --inittests < ./findings/$x/crashes/$y" \
            -ex 'quit';
    done
done