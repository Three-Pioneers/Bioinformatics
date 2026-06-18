#python bin/statistic_mapping.py --bamqc_dir analysis/2.mapping/bamqc/ --output analysis/2.mapping/stats/

import sys
import argparse
import os
import json

parser = argparse.ArgumentParser()
parser.add_argument("-i", "--bamqc_dir",help="bamqc_dir")
parser.add_argument("-o", "--output",help="output")
args = parser.parse_args()

input_bamqc_dir=args.bamqc_dir
stats_out_dir=args.output

mapping_stats=stats_out_dir+'/Statistic_Mapping.txt'
out=open(mapping_stats,"w")
out.write('Sample_ID'+'\t'+'Number Reads'+'\t'+'Mapped Reads'+'\t'+'Mean Mapping Quality'+'\n')

for i in os.listdir(input_bamqc_dir):
    name=i.split("_bamqc")[0]
    bamqc_result=input_bamqc_dir+'/'+i+'/genome_results.txt'
    file=open(bamqc_result,"r")
    line=file.read()
    number_reads=line.split("number of reads = ")[1].split("\n")[0]
    mapped_reads=line.split("number of mapped reads = ")[1].split("\n")[0]
    mean_mapping_quality=line.split("mean mapping quality = ")[1].split("\n")[0]


    out.write(name+'\t'+number_reads+'\t'+mapped_reads+'\t'+mean_mapping_quality+'\n')


