#!/bin/bash

if [ "$#" -ne 5 ]; then
	echo "Usage: ./lmdb_suite.sh <fs> <lmdb_dir> <mnt> <result_dir> <run>"
	exit 1
fi

set -e

fs=$1
lmdbDir=$2
mnt=$3
resultDir=$4/$fs/lmdb
run=$5

curDir=`readlink -f ./`

mkdir -p $resultDir

for workload in fillseqbatch 
do
	echo "$fs LMDB workload $workload Run $run"
	cd $curDir
	./lmdb_workload.sh $fs $lmdbDir $mnt $workload $resultDir $run
	cd $curDir
done
