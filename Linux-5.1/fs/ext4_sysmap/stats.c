/*
 * NOVA File System statistics
 *
 * Copyright 2015-2016 Regents of the University of California,
 * UCSD Non-Volatile Systems Lab, Andiry Xu <jix024@cs.ucsd.edu>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms and conditions of the GNU General Public License,
 * version 2, as published by the Free Software Foundation.
 *
 * This program is distributed in the hope it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
 */

#include "ext4.h"

const char *Timingstring[TIMING_NUM] = {

	/* Namei operations */
	"============= Directory operations =============",
	"lookup",
	"link",
	"symlink",
	"mkdir",
	"rmdir",
	"mknod",
	"rename",
	"readdir",
	"add_dentry",
	"remove_dentry",

	/* I/O operations */
	"================ I/O operations ================",

	/* Memory operations */
	"============== Memory operations ===============",
	"memcpy_read_nvmm",
	"memcpy_write_nvmm",

	/* Memory management */
	"============== Memory management ===============",
	"alloc_blocks",
	"free_blocks",

	/* Others */
	"================ Miscellaneous =================",
	"fallocate",

	/* Mmap */
	"=============== MMap operations ================",
	"mmap_page_fault",
	"mmap_pmd_fault",

	/* Write operation */
	"=============== Write operations ================",
	"write_iter",
	"allocate_blocks",
	"zeroout_blocks",
	"add_blocks_es",
	"write_iomap_begin",
	"write_iomap_end",
	"dax_iomap_rw",

	/* Read operation */
	"=============== Read operations ================",
	"read_iter",
	"lookup_blocks",
	"read_iomap_begin",
	
	/* Create operation */
	"=============== Create operations ================",
	"create",
	"get_inode",
	"add_nondir",
	
	/* Fsync operation */
	"=============== Fsync operations ================",
	"fsync",
	"commit_journal",
	
	/* Delete operation */
	"=============== Delete operations ================",
	"unlink",
	"evict_inode",
	"remove_nondir",
	"find_nondir",
	"add_orphan_inode",
};

u64 Timingstats[TIMING_NUM];
DEFINE_PER_CPU(u64[TIMING_NUM], Timingstats_percpu);
u64 Countstats[TIMING_NUM];
DEFINE_PER_CPU(u64[TIMING_NUM], Countstats_percpu);

void ext4_get_timing_stats(void)
{
	int i;
	int cpu;

	for (i = 0; i < TIMING_NUM; i++) {
		Timingstats[i] = 0;
		Countstats[i] = 0;
		for_each_possible_cpu(cpu) {
			Timingstats[i] += per_cpu(Timingstats_percpu[i], cpu);
			Countstats[i] += per_cpu(Countstats_percpu[i], cpu);
		}
	}
}

void ext4_print_timing_stats(struct super_block *sb)
{
	int i;

	ext4_get_timing_stats();

	ext4_info("=========== ext4 kernel timing stats ============\n");
	for (i = 0; i < TIMING_NUM; i++) {
		/* Title */
		if (Timingstring[i][0] == '=') {
			ext4_info("\n%s\n\n", Timingstring[i]);
			continue;
		}

		if (measure_timing || Timingstats[i]) {
			ext4_info("%s: count %llu, timing %llu, average %llu\n",
				Timingstring[i],
				Countstats[i],
				Timingstats[i],
				Countstats[i] ?
				Timingstats[i] / Countstats[i] : 0);
		} else {
			ext4_info("%s: count %llu\n",
				Timingstring[i],
				Countstats[i]);
		}
	}

	ext4_info("\n");
}

static void ext4_clear_timing_stats(void)
{
	int i;
	int cpu;

	for (i = 0; i < TIMING_NUM; i++) {
		Countstats[i] = 0;
		Timingstats[i] = 0;
		for_each_possible_cpu(cpu) {
			per_cpu(Timingstats_percpu[i], cpu) = 0;
			per_cpu(Countstats_percpu[i], cpu) = 0;
		}
	}
}

void ext4_clear_stats(struct super_block *sb)
{
	ext4_clear_timing_stats();
}
