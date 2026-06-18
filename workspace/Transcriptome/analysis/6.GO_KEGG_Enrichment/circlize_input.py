import math
import sys

# 4.DiffGenes/PRPP_vs_Hypoxia/Sig_genes_exprData.txt
file1=open(sys.argv[2],'r')
lines1=file1.readlines()
dict1={}
# 差异表达筛选的差异基因 ID 和 direction 建立字典
for i in lines1[1:]:
    xx=i.strip().split('\t')
    dict1[xx[0]]=xx[-1]

# 6.GO_KEGG_Enrichment/PRPP_vs_Hypoxia
outdir=sys.argv[3]
out_file=outdir+'/GO_circlize_input.txt'
save_GO=open(out_file,'w')
save_GO.write('id'+'\t'+'category'+'\t'+'gene_num.min'+'\t'+'gene_num.max'+'\t'+'gene_num.rich'+'\t'+'-log10Pvalue'+'\t'+'up.regulated'+'\t'+'down.regulated'+'\t'+'rich.factor'+'\n')

# 6.GO_KEGG_Enrichment/PRPP_vs_Hypoxia/Sig_GO_Enrichment.txt
file2=open(sys.argv[1],'r')
lines2=file2.readlines()
for line in lines2[1:]:
    info=line.strip().split('\t')
    id=info[0]
    if info[-1] =='biological_process':
        category='BP'
    if info[-1] =='cellular_component':
        category='CC'
    if info[-1] =='molecular_function':
        category='MF'
    
    # GeneRatio
    list_counts_max=info[2].split('/')
    counts=int(list_counts_max[0])
    max=int(list_counts_max[1])
    # 假设检验自己算？后面不是有吗
    pvalue=-math.log10(float(info[4]))

    num_up=0
    num_down=0
    list_genes=info[10].split('/')
    #print(list_genes)
    for gene in list_genes:
        if dict1[gene]  == 'Up':
            num_up+=1
        if dict1[gene] == 'Down':
            num_down+=1
    ratio=counts/max
    if float(info[4]) < 0.05:
        save_GO.write(id+'\t'+category+'\t'+'0'+'\t'+str(max)+'\t'+str(counts)+'\t'+str(pvalue)+'\t'+str(num_up)+'\t'+str(num_down)+'\t'+str(ratio)+'\n')
