## Desired system configurations for reproducing results mentioned in the paper
- Ubuntu 18.04.1 LTS
- \>= 64GB DRAM
- 2 sockets (28 cores per socket)
- 112 threads (2 threads per core)
- \>= 500GiB Intel Optane DC PM module in each socket
- Support for clwb instructions (Intel cascadelake processor)

We evaluate the performance of WineFS against ext4-DAX, NOVA and xfs-DAX. We do not include SplitFS in the evaluation, as the performance of SplitFS is similar to ext4-DAX for the memory-mapped applications as SplitFS does not optimize memory-mapped applications, which is the main use-case for WineFS. We do not include PMFS because PMFS is not able to finish the process of aging after even a week, due to poor metadata indexing structures.

**Note: We have all the setup and benchmarks ready to run for the evaluators on the provided machine in `/home/sdp/winefs`. For running experiments and generating results, run the following script. This is a convenience script that will evaluate both Memory-Mapped and POSIX applications. The sections below describe how each kind of evaluation can be performed separately.**
```
$ cd scripts/
$ sudo ./artifact_evaluation_experiments.sh <start-run-id> <num-runs> <result-dir> /home/sdp/images /dev/pmem1 /mnt/pmem0

# For example: sudo ./artifact_evaluation_experiments.sh 1 1 /home/sdp/results /home/sdp/images /dev/pmem1 /mnt/pmem0
(This will run all the experiments for one run and results will be stored in /home/sdp/results)
```
Total time taken by the script for 1 run = approximately 6 hours. (Please make sure that the 500 GB PM partition is created on /dev/pmem1, and that the directory /mnt/pmem0 exists; more notes in the sections below).

Results can be parsed by following steps in [parse-MMAP-results](https://github.com/rohankadekodi/WineFS/blob/main/Experiments.md#parse-results) and [parse-POSIX-results](https://github.com/rohankadekodi/WineFS/blob/main/Experiments.md#parse-results-1)

## Evaluation of WineFS's main claims
1. **WineFS expedites the performance of memory-mapped applications in clean and aged file systems.** The reason for better performance is WineFS's hugepage preserving allocator, which results in lower number of page faults. The corresponding result in the paper is shown in Figure 7 (also shown below for reference).

![MMAP Applications](https://github.com/rohankadekodi/WineFS/blob/main/graphs/aged-perf-rocksdb-lmdb.png)
<p align="center"> SOSP Paper Figure 7. Performance on aged file systems </p>

Our evaluation scripts for benchmarking memory-mapped applications are as follows. This script will load a pre-aged file system image and then execute the benchmark. **NOTE: file system aging takes days, so we have provided pre-aged images to aid in easy evaluation.**

```
cd scripts/
sudo ./run_mmap_applications.sh <start-run-id> <num-runs> <result-dir> <aged-image-directory> /dev/pmem1 /mnt/pmem0
cd ..

# For example: sudo ./run_mmap_applications.sh 10 3 ../results /home/sdp/images /dev/pmem1 /mnt/pmem0 
(This will run RocksDB and LMDB for all aged file systems for 3 runs (Run ID 10, 11, 12) and the results will be stored in the results/ directory)
```

**Time taken: Each file-system takes roughly 40 minutes for one run (15 minutes for loading aged image, 20 minutes for RocksDB and 5 minutes for LMDB).** Note: Please make sure that the 500 GB PM partition is created on /dev/pmem1, and that the directory /mnt/pmem0 exists. Also, please keep in mind that RocksDB workloads (especially Run C) have variance. For statistically accurate results, it is advisable to get the average of multiple runs.

#### Parse Results

The output needs to be parsed using the following command, which will generate CSV files that contain the final results. Those CSV files can then be manually inspected, or uploaded to any spreadsheet or plotting utility to visualize the results via a plot. 

```
cd scripts/
python3 parse_rocksdb.py <number-of-filesystems> <fs1> <fs2> ... <num-runs> <start-run-id> <result-dir> <output-csv-file>
cd ..

# For example: python3 parse_rocksdb.py 4 winefs nova ext4 xfs 3 10 ../results/ ../results/rocksdb_output.csv
(This will parse all the rocksdb output files and generate a CSV file)

# For example: python3 parse_lmdb.py 4 winefs nova ext4 xfs 3 10 ../results/ ../results/lmdb_output.csv
(This will parse all the LMDB output files and generate a CSV file)

```

**Note: the absolute performance numbers may be different than the ones submitted in the paper. This can be attributed to firmware changes that are deployed on the NVDIMMs, along with their wear-and-tear over time. But, the relative improvements over other file systems should be the same.**

The output of this experiment shows the performance of all file systems on memory-mapped applications. The script also outputs the number of page faults incurred by each file system --- WineFS should see the lowest number of page faults --- showing that it used the highest number of hugepages.

---

2. **WineFS does not slow down POSIX (system call) applications.** WineFS uses a bunch of optimizations (fine-grained journaling, faster indexing structures, etc.) for expediting POSIX application performance. This results in POSIX applications atop WineFS performing as good as, or better than their performance on competitive file systems (NOTE: we show POSIX performance on clean file systems because they are unaffected by aging). We use the Filebench suite with varmail, fileserver, webserver and webproxy; WiredTiger with fillrandom and readrandom to show performance of POSIX applications. The corresponding result in the paper is Figure 9, which is also shown below for convenience:

![POSIX-Applications](https://github.com/rohankadekodi/WineFS/blob/main/graphs/clean-perf-filebench-wt.png)
<p align="center"> SOSP Paper Figure 9. Performance of applications using POSIX system calls on clean file systems. </p>

Our evaluation scripts for benchmarking POSIX applications is as follows:

```
cd scripts/
sudo ./run_syscall_applications.sh <start-run-id> <num-runs> <result-dir> /dev/pmem1 /mnt/pmem0
cd ..

# For example: sudo ./run_syscall_applications.sh 10 3 ../results/ /dev/pmem1 /mnt/pmem0 
(This will run Filebench and WiredTiger for all fresh file systems for 3 runs (Run ID 10, 11, 12) and the results will be stored in the results/ directory)
```

**Time taken: Each file-system takes roughly 45 minutes for one run (40 minutes for Filebench suite and 5 minutes for WiredTiger)** Note: Please make sure that the 500 GB PM partition is created on /dev/pmem1, and that the directory /mnt/pmem0 exists. 

#### Parse Results
The parsing scripts for the POSIX applications can be executed as shown below. They will produce CSV files similar to the memory-mapped experiment described above.

```
cd scripts/
python3 parse_filebench.py <number-of-filesystems> <fs1> <fs2> ... <num-runs> <start-run-id> <result-dir> <output-csv-file>
cd ..

# For example: python3 parse_filebench.py 4 winefs nova ext4 xfs 3 10 ../results/ ../results/rocksdb_output.csv
(This will parse all the Filebench output files and generate a CSV file)

# For example: python3 parse_wiredtiger.py 4 winefs nova ext4 xfs 3 10 ../results/ ../results/lmdb_output.csv
(This will parse all the WiredTiger output files and generate a CSV file)
```

**Note: the absolute performance numbers may be different than the ones submitted in the paper. This can be attributed to firmware changes that are deployed on the NVDIMMs, along with their wear-and-tear over time. But, the relative improvements over other file systems should be the same.**

The output of this experiment shows the performance of all file systems on popular POSIX applications. Across the board, WineFS performs equal to, or better than the competitive file systems.

---
---

**(OPTIONAL) Here are the instructions for setting up the kernel and benchmarks, and regenerating workloads. The evaluators can follow the steps below in case they have access to a machine with an NVDIMM. The scripts and aged images we have provided above are complete in themselves. The evaluators aren't expected to follow these instructions. They are mainly for transparency.**

## Compile Kernel
**Note: The machine that we have provided already contains the Linux-5.1 kernel. This step can be skipped**

Follow steps mentioned in [Linux-5.1](https://github.com/rohankadekodi/WineFS/tree/main/Linux-5.1)

## Setup Persistent Memory partition
**Note: The machine that we have provided already contains the right partitions, this step can be skipped**

```
$ sudo apt-get install ndctl
$ sudo ndctl disable-namespace namespace1.0
$ sudo ndctl destroy-namespace namespace1.0
$ sudo ndctl create-namespace --mode=fsdax --size=504G --align=1G # This creates the /dev/pmem1 device on socket 1 of the PM machine.
```

---

#### Aging Process
**Note: Aging takes too long so we provide you with aged images in `/home/sdp/images/`. Evaluators needn't perform aging since it can take days.**

We age the images of all file systems using the [Geriatrix](https://github.com/saurabhkadekodi/geriatrix) aging framework and the Agrawal aging profile such that 75% of the file systems are utilized. Each file system takes approximately 2 days to age.

---

### Memory-mapped applications

#### Setup RocksDB with YCSB
Follow steps mentioned in [RocksDB](https://github.com/rohankadekodi/WineFS/blob/main/RocksDB)

#### Setup LMDB with fillseqbatch
Follow steps mentioned in [LMDB](https://github.com/rohankadekodi/WineFS/blob/main/LMDB)

---

### POSIX Applications

#### Setup Filebench
Follow steps mentioned in [Filebench](https://github.com/rohankadekodi/WineFS/tree/main/Filebench)

#### Setup WiredTiger
Follow steps mentioned in [WiredTiger](https://github.com/rohankadekodi/WineFS/tree/main/WiredTiger)


