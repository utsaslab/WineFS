#include "pmfs.h"

const char *Timingstring[TIMING_NUM] = 
{
	"create",
	"new_inode",
	"add_nondir",
	"unlink",
	"evict_inode",
	"find_entry",
	"readdir",
	"xip_read",
	"find_blocks",
	"xip_write",
	"xip_write_fast",
	"write_new_trans",
	"write_commit_trans",
	"allocate_blocks",
	"internal_write",
	"memcpy_read",
	"memcpy_write",
	"remote_fault",
	"local_fault",
	"alloc_blocks",
	"new_trans",
	"add_logentry",
	"commit_trans",
	"mmap_fault",
	"fsync",
	"free_tree",
	"recovery",
};

unsigned long long Timingstats[TIMING_NUM];
u64 Countstats[TIMING_NUM];
u64 IOstats[STATS_NUM];
DEFINE_PER_CPU(u64[STATS_NUM], IOstats_percpu);

atomic64_t fsync_pages = ATOMIC_INIT(0);

void pmfs_get_IO_stats(void)
{
	int i;
	int cpu;

	for (i = 0; i < STATS_NUM; i++) {
		IOstats[i] = 0;
		for_each_possible_cpu(cpu)
			IOstats[i] += per_cpu(IOstats_percpu[i], cpu);
	}
}


void pmfs_print_IO_stats(void)
{
	pmfs_get_IO_stats();
	printk("=========== PMFS I/O stats ===========\n");
	printk("Fsync %ld pages\n", atomic64_read(&fsync_pages));
	printk("Remote writes %llu bytes\n",  IOstats[remote_writes_bytes]);
	printk("Local writes %llu bytes\n",  IOstats[local_writes_bytes]);
	printk("Remote writes %llu bytes\n",  IOstats[remote_reads_bytes]);
	printk("Local writes %llu bytes\n",  IOstats[remote_reads_bytes]);	       
}

void pmfs_print_timing_stats(void)
{
	int i;

	printk("======== PMFS kernel timing stats ========\n");
	for (i = 0; i < TIMING_NUM; i++) {
		if (measure_timing || Timingstats[i]) {
			printk("%s: count %llu, timing %llu, average %llu\n",
				Timingstring[i],
				Countstats[i],
				Timingstats[i],
				Countstats[i] ?
				Timingstats[i] / Countstats[i] : 0);
		} else {
			printk("%s: count %llu\n",
				Timingstring[i],
				Countstats[i]);
		}
	}

	pmfs_print_IO_stats();
}

void pmfs_clear_stats(void)
{
	int i;

	printk("======== Clear PMFS kernel timing stats ========\n");
	for (i = 0; i < TIMING_NUM; i++) {
		Countstats[i] = 0;
		Timingstats[i] = 0;
	}
}
