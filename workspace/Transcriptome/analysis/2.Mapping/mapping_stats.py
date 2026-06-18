import sys


summary_list=sys.argv[1]
out_dir=sys.argv[2]
out_file=out_dir+'/mapping_stats.txt'
out=open(out_file,'w')
out.write('sample_id'+'\t'+'input_reads'+'\t'+'overall_rate'+'\n')
for i in summary_list.split(','):
    sample_id=i.rsplit('/',2)[1]
    # print(i)
    file1=open(i,'r')
    lines1=file1.readlines()
    # print(lines1)

    input_reads=lines1[1].split(': ')[1].strip()
    overall_rate=lines1[-1].split(': ')[-1].strip()

    out.write(sample_id+'\t'+input_reads+'\t'+overall_rate+'\n')






