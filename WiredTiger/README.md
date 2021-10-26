## Setup WiredTiger

1. Install Dependencies
```
$ sudo apt-get install clang-format
```
2. Compile WiredTiger
```
$ make distclean
$ sh autogen.sh
$ ./configure
$ make -j <num-threads>
$ sudo cp .libs/libwiredtiger.so /usr/lib/
$ sudo cp .libs/libwiredtiger-3.2.1.so /usr/lib/
```
3. Compile leveldb_wt
```
$ cd leveldb_wt
$ make db_bench_wiredtiger
$ cd ..
```
