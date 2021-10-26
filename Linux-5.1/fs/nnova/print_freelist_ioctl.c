#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <linux/fs.h>
#include <errno.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>

#define MAXPATHLEN 256

void main() {

    int fd = 0;
    char *ioctl_file_name = (char *) malloc(sizeof(char) * MAXPATHLEN);
    unsigned long hugepages_flag_value = 0x40000000;
    int ret = 0;

    sprintf(ioctl_file_name, "/mnt/pmem0/ioctl_file_%d", getpid());

    fd = open(ioctl_file_name, O_RDWR | O_CREAT, 0666);
    if (fd < 0) {
        printf("%s: file open failed. Error = %s\n", __func__, strerror(errno));
        exit(-1);
    }

    ret = ioctl(fd, 0xBCD00018, &hugepages_flag_value);
    if (ret < 0) {
        printf("%s: ioctl failed. Error = %s\n", __func__, strerror(errno));
        exit(-1);
    } else {
        printf("%s: ioctl passed. Will print free lists\n", __func__, ret);
    }

    free(ioctl_file_name);
    close(fd);
}
