#!/bin/bash

if [ "$#" -ne 13 ]; then
    echo "Illegal number of parameters; Please provide run, fs, <mount_point>, <rocksdb_dir> <workload_dir> <result_dir> rec_val, a_op_val, bd_op_val, c_op_val, f_op_val, e_op_val, num_threads  as the parameter;"
    exit 1
fi

set -e

runId=$1
fs=$2
mountpoint=$3
rocksDbDir=$4
ycsbWorkloadsDir=$5
ResultsDir=$6
rec_values=$7
a_op_values=$8
bd_op_values=$9
c_op_values=${10}
f_op_values=${11}
e_op_values=${12}
num_of_threads=${13}
pmemDir=$mountpoint
databaseDir=$pmemDir/rocksdbtest-1000
splitfsDir=/mnt/ssd/saurabh/Splitfs-dirs/wiredtiger/SplitFS/splitfs

echo Configuration: 20, 24, 64MB
load_parameters=' --write_buffer_size=67108864 --open_files=32768 --level0_slowdown_writes_trigger=20 --level0_stop_writes_trigger=24 --mmap_read=true --mmap_write=true --allow_concurrent_memtable_write=true --disable_wal=false --num_levels=7 --memtable_use_huge_page=true --target_file_size_base=67108864 --max_bytes_for_level_base=268435456 --max_bytes_for_level_multiplier=10 --max_background_compactions=4 --disable_auto_compactions=true'
backup_parameters=' --write_buffer_size=134217728 --open_files=32768 --level0_slowdown_writes_trigger=140 --level0_stop_writes_trigger=200 --mmap_read=true --mmap_write=true --allow_concurrent_memtable_write=true --disable_wal=false --num_levels=7 --memtable_use_huge_page=true --target_file_size_base=67108864 --max_bytes_for_level_base=8589934591 --max_bytes_for_level_multiplier=10 --max_background_compactions=4 --delayed_write_rate=268435456 --subcompactions=24 --hard_pending_compaction_bytes_limit=274877906944 --soft_pending_compaction_bytes_limit=137438953472 --level0_file_num_compaction_trigger=64 --max_background_flushes=2 --max_write_buffer_number=4'
run_parameters=' --write_buffer_size=67108864 --open_files=32768 --level0_slowdown_writes_trigger=20 --level0_stop_writes_trigger=24 --mmap_read=true --mmap_write=true --allow_concurrent_memtable_write=true --disable_wal=false --num_levels=7 --memtable_use_huge_page=true --target_file_size_base=67108864 --max_bytes_for_level_base=268435456 --max_bytes_for_level_multiplier=10 --max_background_compactions=4'
echo parameters: $parameters

ulimit -n 32768
ulimit -c unlimited

mkdir -p $ResultsDir

echo Sleeping for 5 seconds ...
sleep 5

load_workload()
{
    workloadName=$1
    tracefile=$2
    setup=$3

    echo workloadName: $workloadName, tracefile: $tracefile, parameters: $load_parameters, setup: $setup

    resultDir=$ResultsDir/Load$workloadName

    mkdir -p $resultDir

    echo ----------------------- RocksDB YCSB Load $workloadName ---------------------------
    date
    export trace_file=$tracefile
    echo Trace file is $trace_file
    cd $rocksDbDir

    sudo rm -rf $resultDir/*$runId

    cat /proc/vmstat | grep -e "pgfault" -e "pgmajfault" -e "thp" -e "nr_file" 2>&1 | tee $resultDir/pg_faults_before_Run$runId

    sudo dmesg -c > /dev/null

    date
    numactl --cpubind=1 --membind=1 ./db_bench --use_existing_db=0 --benchmarks=ycsb,stats,levelstats,sstables --db=$databaseDir --compression_type=none --threads=${num_of_threads} $load_parameters 2>&1 | tee $resultDir/Run${runId}
    date

    sudo dmesg -c > $resultDir/dmesg_log_Run$runId

    cat /proc/vmstat | grep -e "pgfault" -e "pgmajfault" -e "thp" -e "nr_file" 2>&1 | tee $resultDir/pg_faults_after_Run$runId

    ls -lah $databaseDir/* >> $resultDir/FileInfo$runId
    echo "--------------------------------" >> $resultDir/FileInfo$runId
    ls $databaseDir/ | wc -l >> $resultDir/FileInfo$runId
    echo "--------------------------------" >> $resultDir/FileInfo$runId
    du -sh $databaseDir >> $resultDir/FileInfo$runId

    echo -----------------------------------------------------------------------
}

run_workload()
{
    workloadName=$1
    tracefile=$2
    setup=$3

    echo "workloadName: $workloadName, tracefile: $tracefile, parameters: $run_parameters, setup: $setup"

    resultDir=$ResultsDir/Run$workloadName

    mkdir -p $resultDir

    echo ----------------------- RocksDB YCSB Run $workloadName ---------------------------
    date
    export trace_file=$tracefile
    echo Trace file is $trace_file
    cd $rocksDbDir

    sudo rm -rf $resultDir/*$runId

    cat /proc/vmstat | grep -e "pgfault" -e "pgmajfault" -e "thp" -e "nr_file" 2>&1 | tee $resultDir/pg_faults_before_Run$runId

    sudo dmesg -c > /dev/null

    date
    numactl --cpubind=1 --membind=1 ./db_bench --use_existing_db=1 --benchmarks=ycsb,stats,levelstats,sstables --db=$databaseDir --compression_type=none --threads=${num_of_threads} $run_parameters 2>&1 | tee $resultDir/Run$runId
    date

    sudo dmesg -c > $resultDir/dmesg_log_Run$runId

    cat /proc/vmstat | grep -e "pgfault" -e "pgmajfault" -e "thp" -e "nr_file" 2>&1 | tee $resultDir/pg_faults_after_Run$runId

    echo Sleeping for 5 seconds . .
    sleep 5

    ls -lah $databaseDir/* >> $resultDir/FileInfo$runId
    echo "--------------------------------" >> $resultDir/FileInfo$runId
    ls $databaseDir/ | wc -l >> $resultDir/FileInfo$runId
    echo "--------------------------------" >> $resultDir/FileInfo$runId
    du -sh $databaseDir >> $resultDir/FileInfo$runId

    echo -----------------------------------------------------------------------
}

create_load_trace_files()
{
    wkld=$1
    threads=$2
    rec=$3
    ops=$4

    load_files=$ycsbWorkloadsDir/load${wkld}_$rec

    if [ $threads -eq 1 ]; then
        echo $load_files
        return
    fi

    load_files=${load_files}_1_${threads}

    for ((i = 2 ; i <= $threads ; i++))
    do
        load_files=${load_files},${ycsbWorkloadsDir}/load${wkld}_${rec}_${i}_${threads}
    done

    echo $load_files
}

create_run_trace_files()
{
    wkld=$1
    threads=$2
    rec=$3
    ops=$4

    run_files=$ycsbWorkloadsDir/run${wkld}_${rec}_${ops}

    if [ $threads -eq 1 ]; then
        echo $run_files
        return
    fi

    run_files=${run_files}_1_${threads}

    for ((i = 2 ; i <= $threads ; i++))
    do
        run_files=${run_files},${ycsbWorkloadsDir}/run${wkld}_${rec}_${ops}_${i}_${threads}
    done

    echo $run_files
}

setup_expt()
{
    setup=$1

    sudo rm -rf $pmemDir/rocksdbtest-1000

    loada_files=`create_load_trace_files a $num_of_threads $rec_values $a_op_values`
    runa_files=`create_run_trace_files a $num_of_threads $rec_values $a_op_values`
    runb_files=`create_run_trace_files b $num_of_threads $rec_values $bd_op_values`
    runc_files=`create_run_trace_files c $num_of_threads $rec_values $c_op_values`
    rund_files=`create_run_trace_files d $num_of_threads $rec_values $bd_op_values`
    runf_files=`create_run_trace_files f $num_of_threads $rec_values $f_op_values`
    loade_files=`create_load_trace_files e $num_of_threads $rec_values $e_op_values`
    rune_files=`create_run_trace_files e $num_of_threads $rec_values $e_op_values`

    load_workload a $loada_files $setup
    sleep 5

    run_workload a $runa_files $setup
    sleep 5

    run_workload b $runb_files $setup
    sleep 5

    run_workload c $runc_files $setup
    sleep 5

    run_workload f $runf_files $setup
    sleep 5

    run_workload d $rund_files $setup
    sleep 5

    sudo rm -rf $pmemDir/rocksdbtest-1000
    load_workload e $loade_files $setup
    sleep 5

    run_workload e $rune_files $setup
    sleep 5
    sudo rm -rf $pmemDir/rocksdbtest-1000
}

setup_expt $fs
