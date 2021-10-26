#!/bin/bash

if [ "$#" -ne 5 ]; then
	echo "Usage: ./mount_fs.sh <fs(ext4/nova/xfs/winefs)> <dev> <mnt> <aged-images-dir> <create(0/1)>"
	exit 1
fi


set -x

fs=$1
dev=$2
mnt=$3
agedImagesDir=$4
create=$5

umount $mnt

if [ "$fs" == "ext4" ]; then
	if [ $create -eq 1 ]; then
		sudo mkfs.ext4 -b 4096 $dev -F
	else
		sudo ./restore_aged_images.sh $fs $agedImagesDir/${fs}_495G_75.img $dev
	fi	
	sudo mount -o dax $dev $mnt
elif [ "$fs" == "xfs" ]; then
	if [ $create -eq 1 ]; then
		sudo mkfs.xfs -b size=4096 -m reflink=0 $dev -f
	else
		sudo ./restore_aged_images.sh $fs $agedImagesDir/${fs}_495G_75.img $dev
	fi
	sudo mount -o dax $dev $mnt
elif [ "$fs" == "nova" ]; then
	sudo modprobe nova
	if [ $create -eq 1 ]; then
		sudo mount -t NOVA -o init $dev $mnt
	else
		sudo ./restore_aged_images.sh $fs $agedImagesDir/${fs}_495G_75.img $dev
		sudo mount -t NOVA -o data_cow $dev $mnt
	fi
elif [ "$fs" == "winefs" ]; then
	sudo modprobe winefs 
	if [ $create -eq 1 ]; then
		sudo mount -t winefs -o init $dev $mnt
	else
		sudo ./restore_aged_images.sh $fs $agedImagesDir/${fs}_495G_75.img $dev
		sudo mount -t winefs -o strict $dev $mnt
	fi
fi
