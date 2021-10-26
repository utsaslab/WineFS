#!/bin/bash

if [ "$#" -ne 5 ]; then
	echo "Usage: ./run_syscall_applications.sh <start-run-id> <num-runs> <result-dir> <dev> <mnt>"
	exit 1
fi

set -e

startRunId=$1
numRuns=$2
resultDir=`readlink -f $3`
dev=$4
mnt=$5

filebenchDir=`readlink -f ../Filebench`
wiredTigerDir=`readlink -f ../WiredTiger`
curDir=`readlink -f ./`

./cpu_scaling_governer.sh

for ((i = $startRunId ; i < $((startRunId + numRuns)) ; i++))
do
	for fs in winefs nova ext4 xfs
	do
		for workload in varmail.f fileserver.f webserver.f webproxy.f
		do
			./mount_fs.sh $fs $dev $mnt null 1
			cd $curDir
			echo "$fs FILEBENCH workload $workload Run $run"
			./filebench_workload.sh $fs $filebenchDir $mnt $workload $resultDir/$fs/filebench $i
			cd $curDir
			sleep 30
		done

		./mount_fs.sh $fs $dev $mnt null 1
		./wiredtiger_suite.sh $fs $wiredTigerDir/leveldb_wt $mnt $resultDir $i
		sleep 30
	done
done
