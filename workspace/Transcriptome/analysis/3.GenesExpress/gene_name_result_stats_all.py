import sys
gene_id_name=sys.argv[1]
file1=open(gene_id_name,'r')
lines1=file1.readlines()
dict1={}
for i in lines1:
    xx=i.strip().split('\t')
    dict1[xx[0]]=xx[1]

gene_id_dir=sys.argv[2]
outdir=sys.argv[3]

old_count=gene_id_dir+'/COUNT.txt'
file2=open(old_count,'r')
lines2=file2.readlines()
new_count=outdir+'/COUNT.txt'
out2=open(new_count,'w')
out2.write(lines2[0])
# 如果 gene_id 有 gene_name 就在后面附上；没有就做本来输出
for i in lines2[1:]:
    xx=i.split('\t',1)
    if xx[0] in dict1:
        out2.write(xx[0]+'('+dict1[xx[0]]+')'+'\t'+xx[1])
    else:
        out2.write(xx[0]+'\t'+xx[1])

old_fpkm=gene_id_dir+'/FPKM.txt'
file3=open(old_fpkm,'r')
lines3=file3.readlines()
new_fpkm=outdir+'/FPKM.txt'
out3=open(new_fpkm,'w')
out3.write(lines3[0])
for i in lines3[1:]:
    xx=i.split('\t',1)
    if xx[0] in dict1:
        out3.write(xx[0]+'('+dict1[xx[0]]+')'+'\t'+xx[1])
    else:
        out3.write(xx[0]+'\t'+xx[1])

old_TPM=gene_id_dir+'/TPM.txt'
file4=open(old_TPM,'r')
lines4=file4.readlines()
new_TPM=outdir+'/TPM.txt'
out4=open(new_TPM,'w')
out4.write(lines4[0])
for i in lines4[1:]:
    xx=i.split('\t',1)
    if xx[0] in dict1:
        out4.write(xx[0]+'('+dict1[xx[0]]+')'+'\t'+xx[1])
    else:
        out4.write(xx[0]+'\t'+xx[1])