import sys
# All_genes_exprData.txt
file_str=sys.argv[1]
# 4.DiffGenes/
outdir=sys.argv[2]

out_file=outdir+'/diffExprGene_stats_input.txt'
out=open(out_file,'w')
out.write('group'+'\t'+'direction'+'\t'+'sum'+'\n')

out1_file=outdir+'/diffExprGene_stats.txt'
out1=open(out1_file,'w')
out1.write('group'+'\t'+'Up'+'\t'+'Down'+'\t'+'No'+'\t'+'Total'+'\n')

for i in file_str.strip().split(','):
    name=i.rsplit('/',2)[1]
    file=open(i,'r')
    lines=file.readlines()
    up=0
    down=0
    no=0
    total=0
    for j in lines[1:]:
        xx=j.strip().split('\t')
        if xx[-1] == 'Up':
            up+=1
            total+=1
        if xx[-1] == 'Down':
            down+=1
            total+=1
        if xx[-1] == 'No':
            no+=1
            total+=1
    out.write(name+'\t'+'Up'+'\t'+str(up)+'\n')
    out.write(name+'\t'+'Down'+'\t'+str(down)+'\n')
    out.write(name+'\t'+'No'+'\t'+str(no)+'\n')
    
    out1.write(name+'\t'+str(up)+'\t'+str(down)+'\t'+str(no)+'\t'+str(total)+'\n')