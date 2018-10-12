#!/bin/sh
die() { echo "Error $1"; exit 100; }

OUTPUT_DIR="./findings";

PROCESSORS=
[ "x" = "x$PROCESSORS" ] && which nproc 2>/dev/null >/dev/null && PROCESSORS=`nproc --all`;
[ "x" = "x$PROCESSORS" ] && which grep 2>/dev/null >/dev/null && [ -f /proc/cpuinfo ] && \
    PROCESSORS=`grep -c ^processor /proc/cpuinfo`;
[ "x" = "x$PROCESSORS" ] && die "can't determine number of processors";

CJDNS_DIR=`echo ./cjdns/build_*`;
INPUT_DIR="$CJDNS_DIR/fuzz_inputs/";
[ -e $OUTPUT_DIR ] && INPUT_DIR="-" && echo "Continuing existing fuzz job";
[ -d ./logs ] || mkdir ./logs || die "could not create log directory";

MS=-M
i=0; while [ "x$i" != "x$PROCESSORS" ]; do
    echo "-------------------------------------------------------"
    echo "Launching cjdnsfuzz-$i";
    echo;
    ./afl-*/afl-fuzz -i $INPUT_DIR -o $OUTPUT_DIR $MS "cjdnsfuzz-$i" -- \
        $CJDNS_DIR/test_testcjdroute_c fuzz --quiet --stderr-to errout.txt --inittests 2>&1 >./logs/cjdnsfuzz-$i.log &
    AFL_PID=$!;
    tail -f ./logs/cjdnsfuzz-$i.log &
    TAIL_PID=$!;
    sleep 5;
    kill $TAIL_PID
    kill -0 $AFL_PID || die "Failed to startup fuzz process, some processes may still be running";
    echo;
    echo -e "Launched cjdnsfuzz-$i as pid $AFL_PID";
    echo;
    echo $AFL_PID >> ./fuzzpids
    i=$(expr $i + 1);
    MS=-S
done

./afl-*/afl-whatsup -s $OUTPUT_DIR;