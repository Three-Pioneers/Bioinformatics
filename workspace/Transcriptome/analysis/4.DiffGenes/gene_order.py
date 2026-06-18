import sys
# 3.GenesExpress/3.Gene_name_all/COUNT.txt
file1=open(sys.argv[1],'r')
lines1=file1.readlines()
# sample_info.txt
file2=open(sys.argv[2],'r')
lines2=file2.readlines()
# PRPP_vs_Hypoxia
vs=sys.argv[3]
Treat,Control=vs.strip().split('_vs_')
# analysis//4.DiffGenes/PRPP_vs_Hypoxia
outdir=sys.argv[4]
out_sample_file=outdir+'/sample_info.txt'
out_sample=open(out_sample_file,'w')
out_sample.write(lines2[0])
sample_id=[]
# Treat 组的样本 id 在前；Control 组的样本 id 在后
for i in lines2[1:]:
    xx=i.strip().split('\t')
    if xx[1]==Treat:
        out_sample.write(i)
        sample_id.append(xx[0])
for i in lines2[1:]:
    xx=i.strip().split('\t')
    if xx[1]==Control:
        out_sample.write(i)
        sample_id.append(xx[0])

out_count_file=outdir+'/COUNT.txt'
out_count=open(out_count_file,'w')
lines1_row=lines1[0].strip().split('\t')
# 由 sample_id 顺序，输出 COUNT 对应列的位置
order_list=[]
for id in sample_id:
    for i in range(len(lines1_row)):
        if lines1_row[i]==id:
            order_list.append(i)
#print(order_list)

for i in lines1:
    xx=i.strip().split('\t')
    #print(xx)
    # 输出 id 列
    out_count.write(xx[0]+'\t')
    str_test=''
    # 
    for j in order_list:
        str_test+=xx[j]+'\t'
    out_count.write(str_test.strip()+'\n')
