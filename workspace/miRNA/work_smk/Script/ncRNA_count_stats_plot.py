import matplotlib.pyplot as plt
import sys

file1=open(sys.argv[1],'r')
lines1=file1.readlines()
sample_id_loc={}
n=0
for i in lines1[0].strip().split('\t')[1:]:
    n+=1
    sample_id_loc[i]=n

stats_dict={}
for id in sample_id_loc.keys():
    loc=sample_id_loc[id]
    sum=0
    for i in lines1[1:]:
        xx=i.strip().split('\t')
        sum+=float(xx[loc])
    stats_dict[id]=sum

out_file=sys.argv[2]+'/stats.txt'
out=open(out_file,'w')
out.write('type'+'\t')


# 提取样本名称和对应的数量
samples = list(stats_dict.keys())
values = list(stats_dict.values())

str1=''
for i in samples:
    str1+=i+'\t'
out.write(str1.strip()+'\n')
type=sys.argv[2].split('/')[-2].split('.')[1]
out.write(type+'\t')
str2=''
for i in values:
    str2+=str(i)+'\t'
out.write(str2.strip()+'\n')
# 创建柱状图，去掉背景线
plt.figure(figsize=(10, 10))  # 图表大小
bars=plt.bar(samples, values, color='skyblue')

# 添加标题和标签
#plt.title('Sample Quantities', fontsize=16)
plt.xlabel('Samples', fontsize=12)
plt.ylabel('Quantity', fontsize=12)

for bar in bars:
    yval = bar.get_height()
    plt.text(bar.get_x() + bar.get_width()/2, yval + 10000, round(yval), ha='center', va='bottom', fontsize=10)

# 去掉背景网格线和边框
plt.grid(False)  # 去掉网格线
plt.gca().spines['top'].set_visible(False)  # 去掉顶部边框
plt.gca().spines['right'].set_visible(False)  # 去掉右边框

# 显示图形
plt.xticks(rotation=45)  # 旋转X轴标签以避免重叠
plt.tight_layout()  # 自动调整布局
# 保存为PDF和PNG文件
png=sys.argv[2]+'/stats.png'
pdf=sys.argv[2]+'/stats.pdf'
plt.savefig(png)
plt.savefig(pdf)




