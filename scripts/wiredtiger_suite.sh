#!/bin/bash

if [ "$#" -ne 5 ]; then
	echo "Usage: ./wiredtiger.sh <fs> <wiredtiger_dir> <mnt> <result_dir> <run>"
	exit 1
fi

set -e

fs=$1
wtDir=$2
mnt=$3
resultDir=$4/$fs/wiredtiger
run=$5

curDir=`readlink -f ./`

mkdir -p $resultDir

for workload in fillrandom,readrandom 
do
	echo "$fs WIREDTIGER workload $workload Run $run"
	cd $curDir
	./wiredtiger_workload.sh $fs $wtDir $workload $mnt $resultDir $run
	cd $curDir
done
