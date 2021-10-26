#!/bin/bash

if [ "$#" -ne 6 ]; then
	echo "Usage: ./wiredtiger_workload.sh <fs> <wiredtiger_dir> <workload> <mnt> <result_dir> <run_id>"
	exit 1
fi

set -e

fs=$1
wtDir=$2
workload=$3
mnt=$4
resultDir=$5
run=$6

cd $wtDir

sync; echo 3 > /proc/sys/vm/drop_caches
numactl --cpubind=1 ./db_bench_wiredtiger --use_lsm=0 --db=$mnt/wt-db --value_size=1024 --benchmarks=$workload --use_existing_db=0 --num=1000000 --threads=4 2>&1 | tee ${resultDir}/${workload}_Run$run.out
sudo rm -rf $mnt/wt-db
