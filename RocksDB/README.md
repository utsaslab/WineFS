## Setup RocksDB with YCSB

1. Install RocksDB dependencies: 
```
$ sudo apt-get install libgflags-dev
```
2. Compile RocksDB: 
```
$ make release -j <num-threads>
```
3. Install YCSB dependencies:
```
$ sudo apt-get install maven
$ sudo apt-get install python2
```
4. Compile YCSB:
```
$ cd YCSB
$ mvn install -DskipTests
$ cd ..
```
5. Generate YCSB Workloads:
```
$ cd YCSB
$ ./generate_workloads.sh # This will generate workloads in ../ycsb_workloads/ directory
$ cd ..
```
