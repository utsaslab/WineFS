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

void main(int argc, char *argv[]) {

    int fd = 0;
    char *ioctl_file_name = (char *) malloc(sizeof(char) * MAXPATHLEN);
    unsigned int ioctl_flag = 0xBCD00013;
    int ret = 0;
    char *mount_point = (char *) malloc(sizeof(char) * MAXPATHLEN);

    if (argc != 2) {
	    printf("Usage: %s <mount-point>\n", argv[0]);
	    exit(-1);
    }

    strcpy(mount_point, argv[1]);
    sprintf(ioctl_file_name, "%s/ioctl_file_%d", mount_point, getpid());

    fd = open(ioctl_file_name, O_RDWR | O_CREAT, 0666);
    if (fd < 0) {
        printf("%s: file open failed. Error = %s\n", __func__, strerror(errno));
        exit(-1);
    }

    ret = ioctl(fd, ioctl_flag, &ret);
    if (ret < 0) {
        printf("%s: ioctl failed. Error = %s\n", __func__, strerror(errno));
        exit(-1);
    } else {
        printf("%s: ioctl passed. Cleared stats\n", __func__);
    }

    free(mount_point);
    free(ioctl_file_name);
    close(fd);
}
