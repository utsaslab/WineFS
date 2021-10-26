#!/bin/bash

source /usr/local/bin/setenv-for-gcc650.sh
make clean
make -j
sudo umount /mnt/pmem_emul
sudo rmmod nova
sudo insmod ./nova.ko measure_timing=1
sudo mount -t NOVA -o init /dev/mapper/linear-pmem /mnt/pmem_emul
sudo chown -R rohan:rohan /mnt/pmem_emul
