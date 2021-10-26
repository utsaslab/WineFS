#!/bin/bash

if [ "$#" -ne 7 ]; then
    echo "Illegal number of parameters; Please provide num_threads, rec_val, a_op_val, bd_op_val, c_op_val, f_op_val, e_op_val  as the parameter;"
    exit 1
fi

set -x

num_threads=$1
rec_val=$2
a_op_val=$3
bd_op_val=$4
c_op_val=$5
f_op_val=$6
e_op_val=$7

rm command_file.sh

for load_workload in a e
do
    num_lines=`wc -l ./load${load_workload}_${rec_val} | awk '{ print $1 }'`
    lines_in_each_thread=$(($num_lines/$num_threads))
    start_line=1
    for ((file_num = 1 ; file_num <= $num_threads ; file_num++))
    do
        sed_var="sed -n '"
        sed_var=${sed_var}${start_line}
        sed_var=${sed_var},
        sed_var=${sed_var}$(($file_num*$lines_in_each_thread))
        sed_var=${sed_var}p
        sed_var=${sed_var}"' "
        sed_var=${sed_var}"./load${load_workload}_${rec_val} > ./load${load_workload}_${rec_val}_${file_num}_${num_threads}"
        start_line=$(($start_line+$lines_in_each_thread))
        echo ${sed_var} >> command_file.sh
    done
done

for run_workload in a b c d e f
do
    if [ "$run_workload" = "a" ]; then
        op_val=$a_op_val
    elif [ "$run_workload" = "c" ]; then
        op_val=$c_op_val
    elif [ "$run_workload" = "f" ]; then
        op_val=$f_op_val
    elif [ "$run_workload" = "e" ]; then
        op_val=$e_op_val
    else
        op_val=$bd_op_val
    fi
    num_lines=`wc -l ./run${run_workload}_${rec_val}_${op_val} | awk '{ print $1 }'`
    lines_in_each_thread=$(($num_lines/$num_threads))
    start_line=1
    for ((file_num = 1 ; file_num <= $num_threads ; file_num++))
    do
        sed_var="sed -n '"
        sed_var=${sed_var}${start_line}
        sed_var=${sed_var},
        sed_var=${sed_var}$(($file_num*$lines_in_each_thread))
        sed_var=${sed_var}p
        sed_var=${sed_var}"' "
        sed_var=${sed_var}"./run${run_workload}_${rec_val}_${op_val} > ./run${run_workload}_${rec_val}_${op_val}_${file_num}_${num_threads}"
        start_line=$(($start_line+$lines_in_each_thread))
        echo ${sed_var} >> command_file.sh
    done
done

chmod +x command_file.sh
