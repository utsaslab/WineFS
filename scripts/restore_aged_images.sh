#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Illegal number of parameters; Please provide fs, <img-file>, <dev-file>  as the parameter;"
    exit 1
fi

set -x

fs=$1
imgfile=$2
devfile=$3

if [ "$fs" == "splitfs" ]; then
    sudo qemu-img convert -O raw $imgfile $devfile
elif [ "$fs" == "ext4" ]; then
    sudo qemu-img convert -O raw $imgfile $devfile
    e2image -Q $devfile $imgfile
elif [ "$fs" == "xfs" ]; then
    sudo xfs_mdrestore -i $imgfile $devfile
elif [ "$fs" == "nova" ]; then
    dd if=$imgfile status=progress | unpigz --fast > $devfile
elif [ "$fs" == "pmfs" ]; then
    dd if=$imgfile status=progress | unpigz --fast > $devfile
elif [ "$fs" == "winefs" ]; then
    dd if=$imgfile status=progress | unpigz --fast > $devfile
fi
