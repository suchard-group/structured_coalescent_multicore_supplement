#!/usr/bin/env bash

# -----------------------------------------
# Configuration
# -----------------------------------------

# Set path to BEAGLE lib
export LD_LIBRARY_PATH=$HOME/beagle-lib/build/usr/local/beagle-basta/lib

# Set path to BEAST jar
BEAST_JAR=$HOME/Documents/beast-mcmc/build/dist/beast.jar

# Path to your XML files
XML_FOLDER="CPU_parallel_BIT_SCA/benchmark/comparisons/beastx"

# Where to write all outputs and logs
OUTPUT_FOLDER="CPU_parallel_BIT_SCA/benchmark/NewBenchmarkResults"

# Thread counts to test: 1 = no threading, others = that many OpenMP threads
THREAD_COUNTS=(1 2 4 8 16)

# -----------------------------------------
# Prepare output directory and results file
# -----------------------------------------

mkdir -p "$OUTPUT_FOLDER"
RESULTS_FILE="$OUTPUT_FOLDER/benchmark_results.txt"

echo "Benchmark results — $(date)" > "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

# -----------------------------------------
# Benchmark loop
# -----------------------------------------

for xml_file in "$XML_FOLDER"/*.xml; do
    base_name=$(basename "$xml_file" .xml)

    for thread_count in "${THREAD_COUNTS[@]}"; do
        echo "Processing ${base_name} with ${thread_count} thread(s)..."

        if [ "$thread_count" -eq 1 ]; then
            # No threading
            COMMON_OPTIONS="-seed 666 -beagle_threading none -overwrite"
        else
            # OpenMP threading
            COMMON_OPTIONS="-seed 666 -beagle_threading openmp -beagle_basta_threads ${thread_count} -overwrite"
        fi

        output_file="$OUTPUT_FOLDER/${base_name}_t${thread_count}_out.txt"
        log_file="$OUTPUT_FOLDER/${base_name}_t${thread_count}_log.txt"

        # Run BEAST
        java -Djava.library.path="${LD_LIBRARY_PATH}" -jar "$BEAST_JAR" $COMMON_OPTIONS -working "$xml_file" \
            > "$output_file" 2>&1

        # Extract timings
        avg_time=$(awk -F'= ' '/average likelihood time/ { print $2 }' "$output_file")

        read acc_tot acc_cnt <<< $(awk '/beagleAccumulateBastaPartials/ { print $2, $4 }' "$output_file")
        acc_avg=$(awk -v t="$acc_tot" -v c="$acc_cnt" 'BEGIN { printf "%.2f", t/c }')

        read upd_tot upd_cnt <<< $(awk '/beagleUpdateBastaPartials/ { print $2, $4 }' "$output_file")
        upd_avg=$(awk -v t="$upd_tot" -v c="$upd_cnt" 'BEGIN { printf "%.2f", t/c }')

        read tr_tot tr_cnt <<< $(awk '/beagleUpdateTransitionMatrices/ { print $2, $4 }' "$output_file")
        tr_avg=$(awk -v t="$tr_tot" -v c="$tr_cnt" 'BEGIN { printf "%.2f", t/c }')

        # Append to summary
        {
            echo "${base_name} (threads=${thread_count}):"
            echo "  average likelihood time: ${avg_time} ms"
            echo "  beagleAccumulateBastaPartials avg: ${acc_avg} ns (total ${acc_tot} ns / ${acc_cnt} ops)"
            echo "  beagleUpdateBastaPartials    avg: ${upd_avg} ns (total ${upd_tot} ns / ${upd_cnt} ops)"
            echo "  beagleUpdateTransitionMatrices avg: ${tr_avg} ns (total ${tr_tot} ns / ${tr_cnt} ops)"
            echo ""
        } >> "$RESULTS_FILE"

        # Keep a full log per run
        cp "$output_file" "$log_file"
    done
done

echo "Benchmarking completed. Results saved in $RESULTS_FILE."

