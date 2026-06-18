import sys
# 3.GenesExpress/0.featureCounts/featureCounts.txt
list_file=sys.argv[1]
# 3.GenesExpress/1.Gene_id
outdir=sys.argv[2]

# 输出 COUNT.txt TPM.txt FPKM.txt
count_file=outdir+'/COUNT.txt'
TPM_file=outdir+'/TPM.txt'
FPKM_file=outdir+'/FPKM.txt'
out_count=open(count_file,'w')
out_TPM=open(TPM_file,'w')
out_FPKM=open(FPKM_file,'w')

import pandas as pd

# 读取featureCounts输出文件
df = pd.read_csv(list_file, sep='\t', comment='#')
#print(df)
# 处理列名：将样本路径转换为简化的样本名称
original_columns = df.columns.tolist()
#print(original_columns)
sample_columns = original_columns[6:]  # 前6列为元数据列
sample_names = [col.split('/')[-2] for col in sample_columns]  # 提取A1/B1等样本名
#print(sample_columns)
#print(sample_names)
# 更新数据框列名
df.columns = original_columns[:6] + sample_names
#print(df.columns)

# 构建COUNT矩阵
count_df = df[['Geneid'] + sample_names].rename(columns={'Geneid': 'id'})
#print(count_df)
print(type(count_df))

# 提取基因长度信息
gene_lengths = df['Length'].values
#print(gene_lengths)
# pandas 直接对矩阵进行计算？
# 计算FPKM矩阵
fpkm_df = count_df.copy()
for sample in sample_names:
    total_counts = count_df[sample].sum()
    fpkm_df[sample] = (count_df[sample] * 1e9) / (gene_lengths * total_counts)

# 计算TPM矩阵
tpm_df = count_df.copy()
for sample in sample_names:
    rpk = count_df[sample] * 1e3 / gene_lengths  # Reads Per Kilobase
    tpm = (rpk / rpk.sum()) * 1e6                # Transcripts Per Million
    tpm_df[sample] = tpm

# 保存结果文件
count_df.to_csv(out_count, sep='\t', index=False)
fpkm_df.to_csv(out_FPKM, sep='\t', index=False)
tpm_df.to_csv(out_TPM, sep='\t', index=False)
