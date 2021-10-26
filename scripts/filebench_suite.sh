#!/bin/bash

if [ "$#" -ne 5 ]; then
	echo "Usage: ./filebench.sh <fs> <filebench_dir> <mnt> <result_dir> <run>"
	exit 1
fi

set -e

fs=$1
filebenchDir=$2
mnt=$3
resultDir=$4/$fs/filebench
run=$5

curDir=`readlink -f ./`
resultDirFull=`readlink -f $resultDir`

mkdir -p $resultDir
mkdir -p $resultDirFull

for workload in varmail.f fileserver.f webserver.f webproxy.f
do
	echo "$fs FILEBENCH workload $workload Run $run"
	cd $curDir
	./filebench_workload.sh $fs $filebenchDir $mnt $workload $resultDirFull $run
	cd $curDir
done

