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

#ifndef __STATS_H
#define __STATS_H


/* ======================= Timing ========================= */
enum timing_category {

	/* Namei operations */
	namei_title_t,
	lookup_t,
	link_t,
	symlink_t,
	mkdir_t,
	rmdir_t,
	mknod_t,
	rename_t,
	readdir_t,
	add_dentry_t,
	remove_dentry_t,

	/* I/O operations */
	io_title_t,

	/* Memory operations */
	memory_title_t,
	memcpy_r_nvmm_t,
	memcpy_w_nvmm_t,

	/* Memory management */
	mm_title_t,
	new_blocks_t,
	free_blocks_t,

	/* Others */
	others_title_t,
	fallocate_t,

	/* Mmap */
	mmap_title_t,
	mmap_fault_t,
	pmd_fault_t,

	/* Write operation */
	write_title_t,
	write_iter_t,
	allocate_blocks_t,
	zeroout_blocks_t,
	add_blocks_es_t,
	write_iomap_begin_t,
	write_iomap_end_t,
	dax_iomap_rw_t,

	/* Read operation */
	read_title_t,
	read_iter_t,
	lookup_blocks_t,
	read_iomap_begin_t,

	/* Create operation */
	create_title_t,
	create_t,
	get_inode_t,
	add_nondir_t,

	/* Fsync operation */
	fsync_title_t,
	fsync_t,
	commit_journal_t,

	/* Delete operation */
	delete_title_t,
	unlink_t,
	evict_inode_t,
	remove_nondir_t,
	find_nondir_t,
	add_orphan_inode_t,

	/* Sentinel */
	TIMING_NUM,
};

extern const char *Timingstring[TIMING_NUM];
extern u64 Timingstats[TIMING_NUM];
DECLARE_PER_CPU(u64[TIMING_NUM], Timingstats_percpu);
extern u64 Countstats[TIMING_NUM];
DECLARE_PER_CPU(u64[TIMING_NUM], Countstats_percpu);

typedef struct timespec timing_t;

#define	INIT_TIMING(X)	timing_t X = {0}

#define EXT4_START_TIMING(name, start) \
	{if (measure_timing) getrawmonotonic(&start); }

#define EXT4_END_TIMING(name, start) \
	{if (measure_timing) { \
		INIT_TIMING(end); \
		getrawmonotonic(&end); \
		__this_cpu_add(Timingstats_percpu[name], \
			(end.tv_sec - start.tv_sec) * 1000000000 + \
			(end.tv_nsec - start.tv_nsec)); \
	} \
	__this_cpu_add(Countstats_percpu[name], 1); \
	}


#endif
