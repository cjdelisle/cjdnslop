#!/bin/sh
CJDNS_DIR=`echo ./cjdns/build_*`;
ls ./findings/ | while read x; do
    ls ./findings/$x/crashes | while read y; do
        echo "Trying out: ./findings/$x/crashes/$y";
        echo;
        gdb $CJDNS_DIR/test_testcjdroute_c \
            -ex 'set confirm on' \
            -ex "r fuzz --quiet --inittests < ./findings/$x/crashes/$y" \
            -ex 'quit';
    done
done