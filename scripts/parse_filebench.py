import csv
import sys
import os

# Usage: python3 parse_rocksdb.py <num_fs> <fs1> <fs2> .. <num_runs> <start_run_id> <result_dir> <output_file>

def parse_file(filename, perf_list):
    in_file = open(filename, 'r')
    try:
        perf = 0.0
        lines = in_file.readlines()
        for line in lines:
            if ' ops/s' in line:
                words = line.split()
                ind = words.index('ops/s')
                perf = perf + float(words[ind-1])
        perf_list.append(round(perf, 2))
    finally:
        in_file.close()

def main():
    if len(sys.argv) < 6:
        print('Usage: python3 parse_filebench.py <num_fs> <fs1> <fs2> .. <num_runs> <start_run_id> <result_dir> <output_csv_file)')
        return

    args = sys.argv[1:]

    num_fs = int(args[0])
    fs = []
    for i in range(0, num_fs):
        fs.append(args[i+1])

    num_runs = int(args[num_fs+1])
    start_run_id = int(args[num_fs+2])
    result_dir = args[num_fs+3]
    output_csv_file = args[num_fs+4]

    runs = []
    for i in range(start_run_id, start_run_id + num_runs):
        runs.append(i)

    print('file systems evaluated = ')
    print(fs)
    print('number of runs = ' + str(num_runs) + ', start run id = ' + str(start_run_id))
    print('result directory = ' + result_dir)

    #workloads = ['Loada', 'Runa', 'Runb', 'Runc', 'Rund', 'Rune', 'Runf']

    workloads = ['fileserver.f_','varmail.f_', 'webproxy.f_', 'webserver.f_']
    csv_out_file = open(output_csv_file, mode='w')
    csv_writer = csv.writer(csv_out_file, delimiter=',')

    for workload in workloads:
        rowheader = []
        rowheader.append(workload)
        for filesystem in fs:
            rowheader.append(filesystem)

        csv_writer.writerow(rowheader)

        for run in runs:
            perf_list = []
            perf_list.append('')

            for filesystem in fs:
                result_file = result_dir + '/' + filesystem + '/filebench/' + workload + 'Run' + str(run) + '.out'
                parse_file(result_file, perf_list)

            csv_writer.writerow(perf_list)

        csv_writer.writerow([])

if __name__ == '__main__':
    main()
