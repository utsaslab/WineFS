## Setup LMDB

1. Install Dependencies:
```
$ sudo apt-get install libsnappy-dev
```
2. Compile & Install LMDB: 
```
$ cd libraries/liblmdb
$ make -j <num-threads>
$ sudo make install
$ cd ../..
```
3. Compile dbbench: 
```
$ cd dbbench
$ make
```
