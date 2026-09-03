# Linux

---

数据块：存储文件内容
元数据（文件附加属性）：文件大小、创建时间、创建人等以及 incode（系统识别文件的唯一标识符），名字方便人记不属于 incode，mv 名字后 incode 不变

链接: 硬链接（Hard link）和软链接（Soft link）
硬链接：文件副本，无独立 incode，必须在同一系统文件下创建，源文件必须存在且不能为目录
软链接：包含独立 incode，指向源文件



~~~bash
rsync -a --info=progress2 --delete /database/ server2:/database/
~~~





## 基础命令

~~~bash
# ls（list directory contents）
##	权限	硬链接	创建人		创建人所在组	大小	最后修改时间	相对路径
drwxrwxrwx 1 zhangxuejie zhangxuejie 4096 Mar 10 22:40 Training/
## 列向展示所有 gz 文件
ls *gz|awk -F '.part' '{print$1}'

# pwd（print working directory）
# cd（change directory）
cd -	# 返回刚才目录
~~~

~~~bash
# 文件重命名
rename 's/new/old/' old_load.txt
~~~

~~~bash
# 查找正在运行的 programme 的 ID; 终止运行
ps aux | grep Trinity | grep -v grep | awk '{print $2}' | xargs kill -9

# 一步到位
pkill -9 firefox
~~~

~~~bash
# 创建文件和目录默认权限，公司所有人都在所属组，所以同组权限足够使用
umask 0002
~~~

~~~bash
# 添加新用户, 赋予文件权限
su root
adduser zhangfugui
chmod 765(读写执-读写-读执) filename
~~~

~~~bash
# 不进入环境查看 python 版本号
conda run -n 环境名称 python --version

# 查看当前环境下自己下载的包，不包括依赖
conda env export --from-history

# conda activate 在命令行可以用，在脚本中不可用，原因是激活 conda 默认运行 .bashrc；而 bash 脚本不会加载 .bashrc
conda run -n vs2 
~~~



### awk

名字是因为三个老外作者的姓第一个字母分别是 A W K

~~~bash
# NF（Number of Field）
# NR（）
awk '{print NR}' test.txt
awk '{print NF}' test.txt	# 输出每行字段数
awk '{print $NF}' test.txt	# 每行字段数就是最后一列的列数，$NF 代表最后一列的值；$1 代表第一列，$0 代表整行

# -F '/' 指定 / 为分割符，默认分隔符空格

# （正则）匹配
awk '/^a.*r$/ {print $1}' test.txt	# 正则匹配行以 a 开头 r 结尾，中间任意字符串
awk '$2 == "haha" {print $0}' test.txt	# 打印第二列为 haha 的所有行
awk '$3~/^;/ {print $2"\t"$6}' test.txt	# 打印第三列开头为 ; 的第二列和第六列
awk '$3!~/^;/ {print $2"\t"$6}' test.txt	# 打印第三列开头不是 ; 的第二列和第六列
awk 'NR==1 || NR==2 || NR==4 || NR==6 || NR==8 || NR==10' test.txt

# 数值判断
awk '$3 > 20 || $3 <12 {print $0}' test.txt	# 判断：|| 或；&& 且

# 打印单引号
awk '{print "'\''"}' test.txt
# 打印双引号
awk '{print "\""}' test.txt

# '{printf $1}' 无空格横向输出第一列；printf 格式化输出
~~~



### 文件操作

~~~bash
# less 严格匹配 12 的单词，不包含 1122 1312 等
/\<12\>
~~~

~~~bash
# sed(Stream Editor) ^啥意思
sed 's/^.*addr://g'
sed "1i1231414"
# -i --in-place <edit files in place (makes backup if SUFFIX supplied)>
# d <delete>
~~~

~~~bash
# 文件内容合并重定向输出
cat Step_1.1_qc.sh Step_2_megahit.sh > ../connect.sh
~~~

~~~bash
# grep（global regular expression print）
grep 'Au_60' Step_2_megahit.sh

# -E 启用扩展正则表达式，找出包含任意字符的行；-i 无视大小写
grep -i -E "word1|word2|word3|word4" Step_2_megahit.sh

# ^a 表示以 a 开头；r$ 表示以 r 结尾；.* 表示任意字符（包括空字符）
grep "^a.*r\$" filename.txt	# 实际加不加 \ 都可

# 查找文本中单双引号
grep "'" test.txt
grep "\"" test.txt
~~~

~~~bash
# 比较俩文件大小，相同则没输出
diff file1 file2
~~~

~~~bash
# wc 行数, 单词数(空格, 制表符, 换行符分割), 字符数
wc file.txt
# 打印第四行
wc file.txt | head -n 4 | tail -n 1
~~~

~~~bash
# sort 按照 ASCII 码排列, 数字则按相同顺序的 ASCII 往后排
## -g 按数值排列
## -k 指定 key 排列
## -u 去重
## -k 1,1 第一个字段排序后，仍然按照后续字段排序，因为默认不稳定排序（排序的字段相同时，原文相对顺序不保留），-s 取消默认
# 将以下内容写入文件
apple 5 red
banana 3 yellow
apple 2 green
cherry 1 red

sort -k 1 text.txt
sort -k 1,1 text.txt
sort -k 1,1 -s text.txt
~~~

~~~bash
# csvtk cut: select and arrange fields
~~~

~~~bash
# 输出从第四行开始到结尾
tail -n +4 file

# 把文件按行分成两份
head -n 56 file > file1	# 第一份
tail -n +57 file > file2	# 第二份，注意行数要比 head 加一
~~~

~~~bash
mkdir -s file	# 检查文件是否存在且非空
mkdir -d file	# 检查是否为目录
~~~

~~~bash
# 全局替换
%s/2/5/g
# 撤销
u
# 撤销重做
Ctrl + r
# 复制
yy
# 删除当前行及之后所有行
dG
~~~

---

## 脚本

~~~bash

~~~



---

## U 盘挂载卸载

~~~bash
# U 盘挂载
sudo fdisk -l
sudo mount /dev/sds1 /Databackup3	# 前面命名有时需要根据不同盘符来更改数字

# U 盘卸载
sudo umount /Databackup3
~~~
