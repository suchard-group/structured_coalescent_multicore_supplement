# Multicore BIT-SCA: Parallel algorithms for phylogenetic inference under a structured coalescent approximation

This repository contains benchmarking studies for multicore parallelization of structured coalescent models using the structured coalescent approximation (SCA) framework. The project evaluates **Backward-in-Time (BIT) SCA** and **Forward-in-Time (FIT)** approaches in BEAST X implementations, focusing on parallel performance analysis and scaling behavior with OpenMP threading.

## Project Structure

### Analysis Directory (`./analysis/`)

Contains XML configuration files for phylogenetic analyses:

- **BIT/**: Backward-in-Time structured coalescent approximation analyses  
  - `denv1_clusterfinal_BIT.xml` — Dengue virus type 1 dataset analysis  
  - `HA_alignedEd_BIT.xml` — H5N1 hemagglutinin dataset analysis  

- **FIT/**: Forward-in-Time phylogeography analyses  
  - `denv1_clusterfinal_FIT.xml` — Dengue virus type 1 dataset analysis  
  - `HA_alignedEd_FIT.xml` — H5N1 hemagglutinin dataset analysis  

### Benchmark Directory (`./benchmark/`)

Contains benchmarking configurations and scripts:

- **`benchmark_all.sh`** — Master script to run all benchmarking experiments across different thread counts (1, 2, 4, 8, 16).  

- **`comparison/`** — Performance comparison between BEASTX and BEAST2 implementations  
  - `beastx/` — BEASTX benchmark configurations for multiple datasets:  
    - EBLV (European Bat Lyssavirus type 1b)  
    - PEDV (Porcine Epidemic Diarrhea Virus)  
    - ZIKV (Zika Virus)  
  - `beast2/` — BEAST2 benchmark configurations for the same datasets  

- **`scaling/`** — Scaling behavior analysis with varying dataset sizes  
  - Location scaling: `benchmark_full_S02.xml` to `benchmark_full_S26.xml` (2–26 threads)  
  - Sequence scaling: `benchmark_N0128.xml`, `benchmark_N0256.xml`, `benchmark_N0512.xml` (128–512 sequences)  

## Prerequisites

This benchmarking suite requires:

- Java Runtime Environment (JRE) for BEAST execution  
- BEAST X installation with BASTA support  
- BEAGLE library with BIT-SCA and OpenMP support  
- Multi-core CPU system for parallel execution testing  
- OpenMP-capable compiler (GCC, Clang, or Intel)  

## Installation

### BEAGLE Library with BIT-SCA and OpenMP Support

The BEAGLE library must be compiled with flags enabling BASTA and OpenMP parallelization:

```bash
git clone https://github.com/beagle-dev/beagle-lib.git
cd beagle-lib/
mkdir build && cd build/
cmake -DBUILD_BIT=ON -DBUILD_OPENMP=ON -DCMAKE_INSTALL_PREFIX=$HOME/local ..
make && make install
```

**Important cmake flags:**  
- `-DBUILD_BIT=ON` — Enables the BIT-SCA algorithms  
- `-DBUILD_OPENMP=ON` — Enables OpenMP threading for CPU parallelization  

### BEASTX Installation with BASTA Support
```bash
git clone https://github.com/beast-dev/beast-mcmc.git
cd beast-mcmc/
ant
```

In `./benchmark/benchmark_all.sh`, set up `BEAST_JAR` and `LD_LIBRARY_PATH` variables to point to the BEAST JAR file and the BEAGLE library.


## Running Benchmarks

### Complete Benchmark Suite
```bash
cd benchmark/
./benchmark_all.sh
```

This runs all benchmarks across different thread configurations (1–16 threads) using OpenMP with BIT-SCA.

### Individual Analyses

Run specific BIT analyses:

```bash
# BIT analysis with OpenMP threading
java -jar beast.jar -seed 666 -beagle_threading openmp -beagle_basta_threads 8 ./analysis/BIT/denv1_clusterfinal_BIT.xml

# Single-threaded analysis (no threading)
java -jar beast.jar -seed 666 -beagle_threading none ./analysis/BIT/HA_alignedEd_BIT.xml
```


## Output and Analysis

Benchmark results include:

- **Execution logs** with per-thread timing information  
- **Performance metrics** such as:  
  - Average likelihood computation time  
  - `beagleAccumulateBastaPartials` and `beagleUpdateBastaPartials` timing  
  - `beagleUpdateTransitionMatrices` timing  
  - Thread scaling efficiency across 1–16 cores  
- **Summary results** in `benchmark_results.txt`  


## Dataset Information

The XML files and benchmarks include:

- **Benchmark datasets:**  
  - EBLV (51 taxa, 3 demes)  
  - ZIKV (283 taxa, 22 demes)  
  - PEDV (756 taxa, 26 demes)  

- **Real-world analyses:**  
  - Dengue virus serotype 1 (287 taxa, 10 demes, Brazil & South America)  
  - Avian influenza H5N1 HA (192 taxa, 20 demes, Eurasia)  

## Performance Optimization

For optimal performance with BIT-SCA:  
1. Compile BEAGLE with `-DBUILD_BIT=ON -DBUILD_OPENMP=ON`.  
2. Use `-beagle_threading openmp -beagle_basta_threads N` for parallel execution.  
3. Tune `THREAD_COUNTS` (recommended 8–16 cores, as scaling saturates beyond this).  
4. Increase JVM heap size with `-Xmx8g` for large datasets.  

