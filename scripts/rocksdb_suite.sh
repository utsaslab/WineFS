#!/bin/bash

if [ "$#" -ne 6 ]; then
	echo "Usage: ./rocksdb_suite.sh <fs> <mnt> <rocksdb_dir> <workload_dir> <result_dir> <run>"
	exit 1
fi

set -e

fs=$1
mnt=$2
rocksDir=$3
workloadDir=$4
resultDir=$5/$fs/rocksdb
run=$6

curDir=`readlink -f ./`

mkdir -p $resultDir

echo "$fs ROCKSDB Run $run"
cd $curDir
./rocksdb_workload.sh $run $fs $mnt $rocksDir $workloadDir $resultDir 50M 50M 50M 50M 50M 10M 8
cd $curDir
