#!/bin/bash

set -x

home_dir=/home/cc
ycsb_workloads_folder=`readlink -f ./`
ycsb_folder=$home_dir/SplitFS/ycsb
record_count=50000000

operation_count_bd=50000000
operation_count_c=50000000
operation_count_a=50000000
operation_count_f=50000000
operation_count_e=5000000
op_a_var=50M
op_bd_var=50M
op_c_var=50M
op_f_var=50M
op_e_var=1M
rec_var=50M

mkdir -p $ycsb_workloads_folder
cd $ycsb_folder

./bin/ycsb load tracerecorder -p recorder.file=$ycsb_workloads_folder/loada_${rec_var} -p recordcount=$record_count -P workloads/workloada

./bin/ycsb run tracerecorder -p recorder.file=$ycsb_workloads_folder/runa_${rec_var}_${op_a_var} -p recordcount=$record_count -p operationcount=$operation_count_a -p requestdistribution=zipfian -P workloads/workloada

./bin/ycsb run tracerecorder -p recorder.file=$ycsb_workloads_folder/runb_${rec_var}_${op_bd_var} -p recordcount=$record_count -p operationcount=$operation_count_bd -p requestdistribution=zipfian -P workloads/workloadb

./bin/ycsb run tracerecorder -p recorder.file=$ycsb_workloads_folder/runc_${rec_var}_${op_c_var} -p recordcount=$record_count -p operationcount=$operation_count_c -p requestdistribution=zipfian -P workloads/workloadc

./bin/ycsb run tracerecorder -p recorder.file=$ycsb_workloads_folder/runf_${rec_var}_${op_f_var} -p recordcount=$record_count -p operationcount=$operation_count_f -p requestdistribution=zipfian -P workloads/workloadf

./bin/ycsb run tracerecorder -p recorder.file=$ycsb_workloads_folder/rund_${rec_var}_${op_bd_var} -p recordcount=$record_count -p operationcount=$operation_count_bd -p requestdistribution=latest -P workloads/workloadd

./bin/ycsb load tracerecorder -p recorder.file=$ycsb_workloads_folder/loade_${rec_var} -p recordcount=$record_count -P workloads/workloade

./bin/ycsb run tracerecorder -p recorder.file=$ycsb_workloads_folder/rune_${rec_var}_${op_e_var} -p recordcount=$record_count -p operationcount=$operation_count_e -p requestdistribution=zipfian -p scanlengthdistribution=uniform -p maxscanlength=100 -P workloads/workloade
