## WineFS

[WineFS](https://github.com/rohankadekodi/WineFS) is a file system for Persistent Memory (PM) which is aimed at maximizing the performance of memory-mapped applications. WineFS uses a novel dual-allocation policy: the memory-mapped application files are allocated with the help of a huge-page aligned allocator whereas the other POSIX application files are allocated with a hole-filling allocator. With the help of dual allocators, WineFS is able to preserve the huge-page-aligned free extents for the memory-mapped applications, in the presence of aging and at high utilization. WineFS uses per-CPU journaling for crash consistency, thus providing high performance and scalability for metadata-heavy workloads as well. 

WineFS is built by modifying [PMFS](https://github.com/linux-pmfs/pmfs) by Intel. PMFS provides a good base for WineFS, with its fine-grained journaling mechanism and an on-disk layout that avoids free-space fragmentation. The following optimizations have been added to the PMFS codebase: 
(a) PM-optimized per-CPU journaling
(b) alignment-aware allocator and huge page handling on page faults
(c) auxiliary metadata
(d) Crash recovery
(e) hybrid data atomicity mechanism: 500 LOC

**Note: Artifact Evaluation details are in the [Experiments page](https://github.com/rohankadekodi/WineFS/blob/main/Experiments.md)**

## Contents

1. `Linux-5.1/` contains the Linux 5.1 kernel with WineFS, NOVA, PMFS as loadable modules and ext4-DAX, xfs-DAX as built-in modules
2. `RocksDB/` contains RocksDB source code and YCSB benchmarking suite
4. `Filebench/` contains the Filebench source code and benchmarks
5. `LMDB/` contains the LMDB source code and benchmarks
6. `WiredTiger/` contains the WiredTiger source code and benchmarks
7. `scripts/` contains scripts to compile and run workloads and kernel

## Artifact Evaluation

The [Experiments page](https://github.com/rohankadekodi/WineFS/blob/main/Experiments.md)
has a list of experiments evaluating WineFS vs ext4-DAX, NOVA and xfs-DAX. The summary is that WineFS outperforms the other file systems on the memory-mapped workloads (RocksDB and LMDB) by up-to 2x, while matching or outperforming other file systems on the other POSIX workloads (Filebench and WiredTiger). Please see the paper for more details.

## System Requirements

1. Ubuntu 16.04 / 18.04 / 20.04 or Fedora 27 / 30
2. At least 32 GB DRAM
3. At least 4 cores
4. Baremetal machine (Not a VM)
5. Intel Optane DC Persistent Memory module

## Setup Kernel
Follow steps in [Linux-5.1](https://github.com/rohankadekodi/WineFS/tree/main/Linux-5.1) to install the Linux 5.1 kernel which has WineFS as a loadable module.

## Limitations
WineFS is under active development. Although there are no known bugs, we welcome any bug reports or bug fixes. 

## Testing
[PJD POSIX Test Suite](https://www.tuxera.com/community/posix-test-suite/) that tests primarily the metadata operations was run on WineFS successfully. WineFS passes all tests. 

## Contributors

1. [Rohan Kadekodi](https://github.com/rohankadekodi), UT Austin
2. [Saurabh Kadekodi](https://github.com/saurabhkadekodi), Carnegie Mellon University

## Acknowledgements

We thank the National Science Foundation, VMware, Google, and Facebook for partially funding this project. We thank Intel and ETRI IITP/KEIT[2014-3-00035] for providing access to Optane DC Persistent Memory to perform our experiments.

## Contact

Please contact us at `rak@cs.utexas.edu` or `vijayc@utexas.edu` with any questions.
