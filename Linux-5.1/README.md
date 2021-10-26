## Compile & Install Kernel
WineFS currently works with the Linux 5.1 kernel. The source of the kernel is present in `linux-5.1/` directory. Steps:
1. Install Kernel Dependencies:
```
$ sudo apt-get install flex bison libelf-dev libssl-dev kexec-tools 
```
2. Generate Kernel Config:
```
$ cp CONFIG_WINEFS .config
$ make olddefconfig
```
3. Compile Kernel:
```
$ make -j <num-threads> # If there are errors while compiling, please try compiling with gcc-8
$ sudo make modules_install
$ sudo make install
```
4. Boot up in the new kernel:
```
$ sudo kexec -l /boot/vmlinuz-5.1.0 --initrd=/boot/initrd.img-5.1.0 --reuse-cmdline
$ sudo kexec -e # This will boot the new kernel in the machine, the ssh connection will be lost temporarily and must be reconnected
```
5. Load WineFS and NOVA modules:
```
$ sudo modprobe winefs
$ sudo modprobe nova
```
