#!/bin/bash

tests=("how2heap_fastbin_dup" "how2heap_house_of_einherjar" "how2heap_house_of_lore" "how2heap_house_of_spirit" "how2heap_overlapping_chunks" "how2heap_poison_null_byte" "how2heap_tcache_poisoning" "how2heap_unsafe_unlink" "how2heap_unsorted_bin_attack")
bins=("fastbin_dup" "house_of_einherjar" "house_of_lore" "house_of_spirit" "overlapping_chunks" "poison_null_byte" "tcache_poisoning" "unsafe_unlink" "unsorted_bin_attack")

make -C tests clean
make -C tests
rm run.out

for ((i=0; i<${#tests[@]}; i++)); do
    test=${tests[$i]}
    bin=${bins[$i]}
    echo "Running test: $test" >> run.out
    echo "Running bin: $bin" >> run.out

    # Trace instance
    start_trace=$(date +%s%N)
    python heaphopper_client.py  trace -c tests/$test/analysis.yaml -b tests/$test/$bin.bin
    end_trace=$(date +%s%N)
    trace_time=$(echo "scale=9; ($end_trace - $start_trace)/1000000000" | bc)
    # echo "Trace time for ${tests[$i]}: $trace_time seconds"
    trace_time=$(printf "%.9f" $trace_time)
    echo "Trace time for ${tests[$i]}: $trace_time seconds" >> run.out

    # Gen PoC
    start_poc=$(date +%s%N)
    python heaphopper_client.py poc -c tests/$test/analysis.yaml -r tests/$test/$bin.bin-result.yaml -d tests/$test/$bin.bin-desc.yaml -s tests/$test/$bin.c -b tests/$test/$bin.bin
    end_poc=$(date +%s%N)
    poc_time=$(echo "scale=9; ($end_poc - $start_poc)/1000000000" | bc)
    # echo "PoC time for ${tests[$i]}: $poc_time seconds"
    poc_time=$(printf "%.9f" $poc_time)
    echo "PoC time for ${tests[$i]}: $poc_time seconds" >> run.out
    echo "" >> run.out
done
