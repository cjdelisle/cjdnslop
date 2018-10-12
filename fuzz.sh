#!/bin/sh
die() { echo "Error $1"; exit 100; }

OUTPUT_DIR="./findings";

[ "x" = "x$JOBS" ] && which nproc 2>/dev/null >/dev/null && JOBS=`nproc --all`;
[ "x" = "x$JOBS" ] && which grep 2>/dev/null >/dev/null && [ -f /proc/cpuinfo ] && \
    JOBS=`grep -c ^processor /proc/cpuinfo`;
[ "x" = "x$JOBS" ] && die 'can'\''t determine number of processors, try `JOBS=2 ./fuzz`';

i=0; while [ "x$i" != "x$JOBS" ]; do
    ## Safety
    [ "x$i" == "x64" ] && die "JOBS doesn't seem to be a number between 0 and 64";
    i=$(expr $i + 1);
done

CJDNS_DIR=`echo ./cjdns/build_*`;
INPUT_DIR="$CJDNS_DIR/fuzz_inputs/";
[ -e $OUTPUT_DIR ] && INPUT_DIR="-" && echo "Continuing existing fuzz job";
[ -d ./logs ] || mkdir ./logs || die "could not create log directory";

MS=-M
i=0; while [ "x$i" != "x$JOBS" ]; do
    echo "-------------------------------------------------------"
    echo "Launching cjdnsfuzz-$i";
    echo;
    echo '' >./logs/cjdnsfuzz-$i.log
    ./afl-*/afl-fuzz -i $INPUT_DIR -o $OUTPUT_DIR $MS "cjdnsfuzz-$i" -- \
        $CJDNS_DIR/test_testcjdroute_c fuzz --quiet --stderr-to errout.txt --inittests \
            2>>./logs/cjdnsfuzz-$i.log >>./logs/cjdnsfuzz-$i.log &
    AFL_PID=$!;
    tail -f ./logs/cjdnsfuzz-$i.log &
    TAIL_PID=$!;
    # If we get ^C during the process, we still want to kill the tail process...
    ( sleep 5 ; kill $TAIL_PID 2>/dev/null ) &
    sleep 5;
    kill $TAIL_PID 2>/dev/null
    kill -0 $AFL_PID || break;
    echo;
    echo -e "Launched cjdnsfuzz-$i as pid $AFL_PID";
    echo;
    echo $AFL_PID >> ./fuzzpids
    i=$(expr $i + 1);
    MS=-S
done

./afl-*/afl-whatsup -s $OUTPUT_DIR;