#python bin/fastp_stats.py --input_fastp_dir analysis/1.QC/fastp/ --stats_out_dir analysis/1.QC/stats

import sys
import argparse
import os
import json
# 创建解释器
parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input_fastp_dir",help="input_fastp_dir")
parser.add_argument("-o", "--stats_out_dir",help="stats_out_dir")
args = parser.parse_args()
# 赋值
input_fastp_dir=args.input_fastp_dir
stats_out_dir=args.stats_out_dir

qc_stats=stats_out_dir+'/qc_stats.txt'
out=open(qc_stats,"w")
out.write('Sample_ID'+'\t'+'Raw_Total_Reads'+'\t'+'Raw_Total_Bases'+'\t'+'Raw_Q20_Bases'+'\t'+'Raw_Q30_Bases'+'\t'+'Raw_Q20_Rate'+'\t'+'Raw_Q30_Rate'+'\t'+'Raw_GC_Content'+'\t'+'Clean_Total_Reads'+'\t'+'Clean_Total_Bases'+'\t'+'Clean_Q20_Bases'+'\t'+'Clean_Q30_Bases'+'\t'+'Clean_Q20_Rate'+'\t'+'Clean_Q30_Rate'+'\t'+'Clean_GC_Content'+'\t'+'Low_Quality_Reads'+'\t'+'Too_Many_N_Reads'+'\t'+'Too_Short_Reads'+'\n')


for i in os.listdir(input_fastp_dir):
    xx=i.strip().split(".")
    if xx[-1] == "json" :
        json_file=input_fastp_dir+"/"+i
        file=open(json_file,"r")
        # json.load 不能读取 read readlines，他们分别是 “str”，“list”
        json_dict=json.load(file)
        raw_total_reads=format(json_dict['summary']['before_filtering']['total_reads'],',')
        raw_total_reads_test=str(json_dict['summary']['before_filtering']['total_reads'])
        raw_total_bases=format(json_dict['summary']['before_filtering']['total_bases'],',')
        raw_q20_bases=format(json_dict['summary']['before_filtering']['q20_bases'],',')
        raw_q30_bases=format(json_dict['summary']['before_filtering']['q30_bases'],',')
        raw_q20_rate=str(f'%.2f%%' %(100*float(json_dict['summary']['before_filtering']['q20_rate'])))
        raw_q30_rate=str(f'%.2f%%' %(100*float(json_dict['summary']['before_filtering']['q30_rate'])))
        raw_gc_content=str(f'%.2f%%' %(100*float(json_dict['summary']['before_filtering']['gc_content'])))

        clean_total_reads=format(json_dict['summary']['after_filtering']['total_reads'],',')
        clean_total_reads_test=str(json_dict['summary']['after_filtering']['total_reads'])
        clean_total_reads_rat='('+str(f'%.2f%%' %(100*(int(clean_total_reads_test)/int(raw_total_reads_test))))+')'
        clean_total_bases=format(json_dict['summary']['after_filtering']['total_bases'],',')
        clean_q20_bases=format(json_dict['summary']['after_filtering']['q20_bases'],',')
        clean_q30_bases=format(json_dict['summary']['after_filtering']['q30_bases'],',')
        clean_q20_rate=str(f'%.2f%%' %(100*float(json_dict['summary']['after_filtering']['q20_rate'])))
        clean_q30_rate=str(f'%.2f%%' %(100*float(json_dict['summary']['after_filtering']['q30_rate'])))
        clean_gc_content=str(f'%.2f%%' %(100*float(json_dict['summary']['after_filtering']['gc_content'])))

        low_quality_reads=format(json_dict['filtering_result']['low_quality_reads'],',')
        low_quality_reads_test=str(json_dict['filtering_result']['low_quality_reads'])
        low_quality_reads_rat='('+str(f'%.2f%%' %(100*(int(low_quality_reads_test)/int(raw_total_reads_test))))+')'
        too_many_N_reads=format(json_dict['filtering_result']['too_many_N_reads'],',')
        too_many_N_reads_test=str(json_dict['filtering_result']['too_many_N_reads'])
        too_many_N_reads_rat='('+str(f'%.2f%%' %(100*(int(too_many_N_reads_test)/int(raw_total_reads_test))))+')'
        too_short_reads=format(json_dict['filtering_result']['too_short_reads'],',')
        too_short_reads_test=str(json_dict['filtering_result']['too_short_reads'])
        too_short_reads_rat='('+str(f'%.2f%%' %(100*(int(too_short_reads_test)/int(raw_total_reads_test))))+')'
        out.write(xx[0]+'\t'+raw_total_reads+'\t'+raw_total_bases+'\t'+raw_q20_bases+'\t'+raw_q30_bases+'\t'+raw_q20_rate+'\t'+raw_q30_rate+'\t'+raw_gc_content+'\t'+clean_total_reads+clean_total_reads_rat+'\t'+clean_total_bases+'\t'+clean_q20_bases+'\t'+clean_q30_bases+'\t'+clean_q20_rate+'\t'+clean_q30_rate+'\t'+clean_gc_content+'\t'+low_quality_reads+low_quality_reads_rat+'\t'+too_many_N_reads+too_many_N_reads_rat+'\t'+too_short_reads+too_short_reads_rat+'\n')










