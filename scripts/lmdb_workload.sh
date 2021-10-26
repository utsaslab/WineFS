#!/bin/bash

if [ "$#" -ne 6 ]; then
	echo "Usage: ./lmdb_workload.sh <fs> <lmdbDir> <mnt> <workload> <result_dir> <run>"
	exit 1
fi

set -e

fs=$1
lmdbDir=$2
mnt=$3
workload=$4
resultDir=$5
run=$6

cd $lmdbDir

sync && echo 3 > /proc/sys/vm/drop_caches
numactl --cpubind=1 ./t_lmdb --benchmarks=$workload --compression=0 --use_existing_db=0 --threads=1 --batch=100 --num=50000000 2>&1 | tee $resultDir/${workload}_Run$run.out
sudo rm -rf $mnt/lmdb
