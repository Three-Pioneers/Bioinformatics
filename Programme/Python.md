# Python

---

~~~python
import sys
print(sys.argv[0])
print(sys.argv[1:])
print(sys.argv)
print(type(sys.argv))

python sys.py haha ouha hehe
~~~

文件读取F1，F2，F3; 写入out; 读取后直接file1=F1.read()，anno=file.split()



## 字典

~~~python
print(dict)
# 二者相等? 值，类型
print(list(dict))
print(dict.keys())
~~~

读取一个文件内容，如何去除空行



## Pandas

替换脚本中繁琐的循环，改成 [Pandas](https://www.runoob.com/pandas/pandas-intro.html)；需要在 VsCode 中安装 Jupyter 扩展



### 读取文件

~~~python
import pandas as pd

df = pd.read_csv(
    "file.txt",
    sep = "\t",
    header = 0,	# 以第 0 行作为表头；不用则为 None
    skiprows = 3,	# 跳过行的数量
    index_col = ["Chr"]	# 这样会看着奇怪，除[2, 1]外其余第二行其余元素为空，应该有设置方法；也可以用索引
)
~~~



### 排序

~~~python
# 按 Length 列升序排列，默认升序
df = df.sort_values(by = "Length", ascending = True)
# 按 Length 列降序排列
df = df.sort_values(by = "Length", ascending = False)
~~~



### 数据聚合

~~~python
# 根据
df.groupby(by = "Length")
~~~
