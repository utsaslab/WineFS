#!/bin/bash

if [ "$#" -ne 6 ]; then
	echo "Usage: ./filebench.sh <fs> <filebench_dir> <mnt> <workload> <result_dir> <run-id>"
fi

set -e

fs=$1
filebenchDir=$2
mnt=$3
workload=$4
resultDir=$5
run=$6

cd $filebenchDir

mkdir -p $resultDir

echo 0 | sudo tee /proc/sys/kernel/randomize_va_space

sync; echo 3 > /proc/sys/vm/drop_caches
numactl --cpubind=1 ./filebench -f workloads/$workload 2>&1 | tee $resultDir/${workload}_Run$run.out

sudo rm -rf $mnt/bigfileset
sudo rm -rf $mnt/logfiles
