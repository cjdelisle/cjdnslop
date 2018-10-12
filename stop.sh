#!/bin/sh
[ ! -f ./fuzzpids ] && echo "Apparently no fuzzers running" && exit 0;
cat ./fuzzpids | while read pid; do
    kill $pid 2>/dev/null && echo "Stopping fuzzer $pid";
done
sleep 1;
cat ./fuzzpids | while read pid; do
    kill -9 $pid 2>/dev/null  && echo "Killing fuzzer $pid";
done
rm ./fuzzpids;