#!/bin/bash

if [ "$#" -ne 6 ]; then
	echo "Usage: ./run_mmap_applications.sh <start-run-id> <num-runs> <result-dir> <aged-images-dir> <dev> <mnt>"
	exit 1
fi

set -e

startRunId=$1
numRuns=$2
resultDir=`readlink -f $3`
agedImagesDir=$4
dev=$5
mnt=$6

rocksDbDir=`readlink -f ../RocksDB`
ycsbWorkloadDir=`readlink -f ../RocksDB/ycsb_workloads`
lmdbDir=`readlink -f ../LMDB`

./cpu_scaling_governer.sh

for ((i = $startRunId ; i < $((startRunId + numRuns)) ; i++))
do
	for fs in winefs nova ext4 xfs 
	do
		./mount_fs.sh $fs $dev $mnt $agedImagesDir 0
		./rocksdb_suite.sh $fs $mnt $rocksDbDir $ycsbWorkloadDir $resultDir $i
		./lmdb_suite.sh $fs $lmdbDir/dbbench/bin $mnt $resultDir $i
		sleep 30
	done
done
