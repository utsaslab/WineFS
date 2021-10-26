#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Illegal number of parameters; Please provide fs, <dev-file>, <img-file>  as the parameter;"
    exit 1
fi

set -x

fs=$1
devfile=$2
imgfile=$3

if [ "$fs" == "splitfs" ]; then
    e2image -Q $devfile $imgfile
elif [ "$fs" == "ext4" ]; then
    e2image -Q $devfile $imgfile
elif [ "$fs" == "xfs" ]; then
    xfs_metadump -a $devfile $imgfile 
elif [ "$fs" == "nova" ]; then
    dd if=$devfile status=progress | pigz --fast > $imgfile
elif [ "$fs" == "pmfs" ]; then
    dd if=$devfile status=progress | pigz --fast > $imgfile
elif [ "$fs" == "winefs" ]; then
    dd if=$devfile status=progress | pigz --fast > $imgfile
fi
