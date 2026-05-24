# 第一部分 入门

+ 第一章：介绍R语言。学习下载扩展包

+ 第二章：R导入数据的方式。学习R存储数据的多种数据结构，手动输入数据；从文本，网页，数据，电子表格导入数据

+ 第三章：R的数据管理。数据集的排序，合并，取子集，及变量的变换，重编码，删除

+ 第四章：ggplot2图形包

+ 第五章：数据管理的数值处理函数和字符处理函数。学习控制结构，编写R函数，重组数据和汇总数据的强大功能

  ```
  # R
  
  ## 基础介绍
  
  ### 数据分析
  
  ==数据分析是为了帮助决策==
  
  数据收集-数据存储-数据统计（统计）-数据挖掘（大数据中发掘有用信息）-数据可视化-帮助决策
  
  ### 数据挖掘
  
  大数据下思维的转变
  
  - 追求全部数据进行分析而非部分数据
  - 追求数据的纷繁复杂而非准确性（允许误差）
  - 追求了解事物的相关关系而非因果关系
  
  大数据只是预测而非万能
  ```

  ### 数据分析

  ==数据分析是为了帮助决策==

  数据收集-数据存储-数据统计（统计）-数据挖掘（大数据中发掘有用信息）-数据可视化-帮助决策

  ### 数据挖掘

  大数据下思维的转变

  - 追求全部数据进行分析而非部分数据
  - 追求数据的纷繁复杂而非准确性（允许误差）
  - 追求了解事物的相关关系而非因果关系

  大数据只是预测而非万能


## 第一章 R介绍

### 1.1 吹吹R

1. 免费
2. 可处理各种数据
3. 统计方法更新快
4. 制图顶级
5. 可交互式处理数据，即输出可再输入
6. 轻松导入各种类型数据
7. 编写函数简单
8. 可被集成在其他程序语言中
9. 可运行在Win，Linux，Mac之上
10. 用户图形界面

### 1.2 R使用

+ 区分大小写
+ 命令执行有交互式（单个）和脚本式（一组）
+ 数据类型：向量，矩阵，数据框，列表
+ 对象任意，可数据、函数、图形、分析结果。每个对象都有自己的类属性，不同类属性操作不同
+ 赋值特殊，屁股尖尖对着的地方 `X <- 15` 或 `15 >- X`
+ '#' 做注释开头
+ 中英文标点符号要注意

#### RStudio

比基础界面功能更强大的编写代码和查看输出结果，即集成开发环境（Integrated Development Environment，IDE）

**原始界面**

<img src="C:\Users\张雪杰\AppData\Roaming\Typora\typora-user-images\image-20240701220258126.png" alt="image-20240701220258126"  />

**代码清单1-1**

```R
age <- c(1,3,5,2,11,9,3,9,12,3)
weight <- c(4.4,5.3,7.2,5.2,8.5,7.3,6.0,10.4,10.2,6.1)
mean(weight)
sd(weight) # 标准差
cor(age,weight) # 线性相关度
plot(age,weight) # 散点图
```

![image-20240701221417159](C:\Users\张雪杰\AppData\Roaming\Typora\typora-user-images\image-20240701221417159.png)

==B 区中的 num[1:10]何意？==

> 顺时针循环依次为A,B,C,D
>
> > A脚本窗口——程序源代码显示位置
> >
> > > TAB键
> > >
> > > - 输入函数开头，会出现一系列函数，选择好后按TAB==选中函数==
> > > - 光标在函数内部时，按TAB==列出函数信息==
> > > - 光标位于引号内部，按TAB==可补全文件路径==
> > >
> > > 代码执行
> > >
> > > - 选中一段代码，点击“run”或者按“Ctrl+Enter”
> > > - 执行全部代码，点击“Ctrl+Shift+Enter”即可
> >
> > B环境窗口——列出已经创建的变量
> >
> > C绘图窗口
> >
> > D控制台窗口——程序在这里运行
> >
> > > 命令提示符为“>”，当出现“+”时，表示解释器在等我们输入完整的语句。原因时输入的代码太长，超出一行限制，或者有不匹配的括号，此时按“Esc”即可变回“>”

#### 帮助

```R
### 光标停留在函数上，点击F1即可打开帮助
help.start()			   		    # 输出通用的帮助信息
help("foo")or"?foo"					# 输出函数foo()的帮助信息
help(package="foo")					# 输出foo包的帮助信息
help.search("foo")or"??foo"		     # 在帮助系统中查找名称中有foo的实例（包，函数，类）的帮助信息
example("foo")				        # 输出函数foo（）的示例信息
data()							   # 输出当前已加载的包中所有可用的示例数据集
vignette()						   # 列出当前已加载的包中所有可用的简介信息
vignette("foo")				        # 输出主题foo的简介信息
```

#### 工作区

即当前R的工作环境，包含了==所有用户==定义的对象

当前工作目录（working directory）—— R用来读取文件和存储结果的默认目录

**表1-3 用于管理R工作区的函数**

```R
getwd()								# 展示当前工作目录
setwd("mydirectory")			      # 修改当前工作目录为mydirectory
ls()								# 列出当前工作区中的对象
rm(objectlist)						 # 移除（删除）一个或多个对象
help(options)						 # 显示可用选项的说明
options()							 # 显示或设置当前选项
save.image("myfile")				  # 保存工作区到文件myfile中（默认值为.RData）
save(objectlist,file="myfile")		   # 保存指定对象到一个文件中
load("myfile")						 # 读取一个工作区到当前会话中（默认值为.RData）
```

**代码清单1-2** ==注意？？？==

```R
setwd("C:/myprojects/project1")
### 如果出现"无法改变工作目录"，原因可能是：1.该目录不存在；2.错误的字符
### 对于1.需要创建一个目录，可用"dir.create("directory")"但是可能出现"No such file or directory，无法创建目录"的原因？？？
options() # 显示当前的选项设置情况
options(digits=3) # 数字将被格式化，显示为小数点后三位有效数字
```

**注**

- setwd()命令的路径中使用了正斜杠 "/" ，R中将反斜杠 "\\" 当作转义字符
- setwd()不会创建一个新目录，若必要可以用 dir.create() 来创建新目录，然后再更改工作目录

### 1.3 包

函数、数据、预编译代码以一种定义完善的格式组成的集合。包必须载入才可使用

电脑上存储包的目录成为==库（library）==

``` R
.libPaths()		# 显示库所在的位置，注意P大写
library()		# 显示库中的包
search()		# 显示已加载可使用的包
```

#### 安装包

```r
install.packages()		# 第一次安装包，括号内加双引号
update.packages()		# 更新包
installed.packages()	# 列出已安装的包，版本号和依赖关系等
```

#### 载入包

```R
library()		# 安装是从站点下载到库中，载入才能使用
### 可自定义启动环境自动载入频繁使用的包——附录B
```

#### 使用包

**多犯错**

- 注意函数大小写
- 必要的引号要注意
- 调用函数时要使用括号
- 使用包前要先载入
- 注意R中 "\\" 表示转义字符，路径用 "/"

### 1.4 实例

**任务描述**

1. 打开帮助文档首页，并浏览其中的"Introduction to R"
2. 安装 vcd 包(一个用于可视化类别数据的包)
3. 列出此包中可用的函数和数据集
4. 载入这个包并阅读数据集 Arthritis 的描述
5. 显示数据集 Arthritis 的内容(直接输入一个对象的名称将列出他的内容)
6. 运行数据集 Arthritis 自带的示例，如果不理解输出结果，也不要担心，结果基本上显示的是接受治疗的关节炎患者比接受安慰剂的患者在病情上有了更多改善

```R
help.start()
install.packages("vcd")				# packages 有 s
help(package ="vcd")				# 区分包和函数；package 没有 s
library("vcd")						# 都要加双引号
help(Arthritis)
Arthritis
example(Arthritis)
```

## 第二章 创建数据集

**重点**

- 数据结构
- 输入数据
- 导入数据
- 标注数据

### 2.2 数据结构

#### 2.2.1 向量(vector)

可存储数值型、字符型、逻辑型数据的一维数组，但一个对象存储的数据类型必须单一

==向量中元素索引位置从1开始==

标量(scalar)，只含一个元素的向量

```R
A <- c(1,3,5,6) # ”c“必须小写，创建一维数值型向量并赋值于 A
A
A[3] #5
A[c(1,3)] #1,5
### A[c(1,3)]不可写成A[1,3]，在矩阵中[1,3]代表一行三列，个人认为报错原因是向量无列
A[c(2:4)] #3,5,6;冒号类似于Python中切片
### A[C(2:4)]也可写成A[2:4]
```

#### 2.2.2 矩阵

二维数组，矩阵中的元素类型唯一(字符型，数值型，逻辑型)

```R
mymatrix <- matrix(vector,nrow=number_of_row,ncol=number_of_col,
                  byrow=logical_value,dimnames=list(
                  char_vector_rowname,char_vector_colname))
### vector包含了矩阵中的所有元素
### nrow为行数，ncol为列数
### logical_value=TRUE，即byrow=TRUE，为按行填充
### logical_value=FALSE，即byrow=FALSE，为按列填充，默认按列填充
### dimnames包含了字符型向量表示的行名和列名
```

**代码清单 2-1 创建矩阵**

```R
Y <- matrix(c(1:20),nrow=5,ncol=4) # 创建一个5×4的矩阵
Y
cells <- c(1,26,24,28)
rnames <- c("R1","R2")
cnames <- c("C1","C2")
mymatrix <- matrix(cells,nrow=2,ncol=2,byrow=TRUE,
                   dimnames=list(rnames,cnames)) # 创建一个2×2按行填充的矩阵
mymatrix
### 变量名称可不用先赋值，直接用数字或字符代替。如"cells"可用c(1,26,24,28)代替
### ”dimnames=list(rnames,cnames)“中，rnames、cnames可直接c("R1","R2")、c("C1","C2")代替
mymatrix <- matrix(cells,nrow=2,ncol=2,byrow=FALSE,
                   dimnames=list(rnames,cnames)) # 创建一个2×2按列填充的矩阵
mymatrix
```

**代码清单 2-2 矩阵下标的使用**

```R
X <- matrix(c(1:10),nrow=2) # 创建一个1到10的按列填充的两行矩阵，c(1:10)可直接1:10
X
X[2,] # 显示第2行的元素
X[,2] # 显示第2列的元素
X[1,4] # 显示第1行第4列的元素
X[1,c(4,5)] # 显示第1行，第4、5列的元素
```

#### 2.2.3 数组

array，数组维度可以大于2

```R
myarray <- array(vector,dimensions,dimnames)
### vector包含了数组中的元素
### dimensions包含了各个唯独下的最大下标
### dimnames是可选的、各维度名称标签的列表
```

**代码清单 2-3 创建一个数组**

```R
dim1 <- c("A1","A2")
dim2 <- c("B1","B2","B3")
dim3 <- c("C1","C2","C3","C4")
z <- array(1:24,c(2,3,4),dimnames=list(dim1,dim2,dim3))
### dim1、dim2、dim3都可直接用字符型代替
z
```

#### 2.2.4 数据框

多种数据类型可以在一起，但是同一列只能有一种类型

__代码清单 2-4 创建一个数据框__

```R
patientID <- c(1,2,3,4)
age <- c(25,34,28,52)
diabetes <- c("Type1","Type2","Type1","Type1")
status <- c("Poor","Improved","Excellent","Poor")
patientdata <- data.frame(patientID,age,diabetes,status)
patientdata
```

__代码清单 2-5 选取数据框中的元素__

```R
patientdata[1:2] # 选取1，2列，按列显示
patientdata[1,] # 选取1行，按行显示
patientdata[1,2] # 选取1行2列
patientdata[c("diabetes","status")] # 可以按照列名选择，切记引号
patientdata$age # 选取数据框中的某个特定变量,按行显示元素
```

**由数据框两列可形成列联表**

```R
table(patientdata$diabetes,patientdata$status)
```

但是$前的前缀烦人，因此引入函数with()

##### with()

```R
### 原方法
mtcars # 包含了32种车型燃油效率数据的数据框
summary(mtcars$mpg) #汇总
plot(mtcars$mpg,mtcars$disp) #绘制图形关系
plot(mtcars$mpg,mtcars$wt)
###—————————————————————————————————————————————————————————————————————————————————————
### 使用With()
with(mtcars,{
    summary(mpg)
    plot(mpg,disp)
    plot(mpg,wt)
})
### 注意mtcars，之后必须要有","
### with()函数里，"{}"中的函数之间不用","
### 不用$符号
```

**特殊赋值符**

with() 函数局限在于赋值仅仅在函数内生效，若想创建全局变量，则需要用 ==<<-==，即特殊赋值符

```R
with(mtcars,{
  stats <- summary(mpg)
  stats
})
stats # 会报错，因为是只存在于with()里的一瞬间的变量
###—————————————————————————————————————————————————————————————————————————————————————
with(mtcars,{
  nokeepstats <- summary(mpg)
  keepstats <<- summary(mpg)
})
nokestats # 报错
keepstats # 用了特殊赋值符号之后不会报错
```

##### 实例标识符

==类似于身份证或者名字一样的可以区分不同人的对象，而不是靠体重或者身高来区分==

```R
patientdata <- data.frame(patientID,age,diabetes,
                          status,row.names=patientID)
```

#### 2.2.5 因子

变量：名义变量（无序）；顺序变量（有序无大小）；连续型变量（有序有大小）

名义变量和顺序变量统称为因子，因子决定了数据的分析方式和视觉呈现

==factor()== 函数以整数对应储存字符型变量，整数范围默认[1,k]，k是字符型变量有几类；整数按照字符型变量的字母顺序赋值

```R
# 设置名义变量
diabetes <- c("Type1","Type2","Type1","Type1")
diabetes <- factor(diabetes) # 将向量存储为(1,2,1,1)，将整数和字符型关联
###
--------------------------------------------------------------------------------------
# 设置顺序变量
status <- c("Poor","Improved","Excellent","Poor")
status <- factor(status,order=TRUE) #将向量存储为(3,2,1,3),将整数和字符型关联
### 这些顺序默认都是按照字母顺序来排序的，若想指定排序
status <- factor(status,order=TRUE,
                levels=c("Poor","Improved","Excellent"))
### 切记是order，而不是ordered
### 数据中有的参数中也一定要有，不能出现三列数据带而只设置了两列参数
###
--------------------------------------------------------------------------------------
# 数值型变量即将数字变为因子
sex <- factor(sex,levels=c(1,2),labels=c("Male","Female"))
# Male,Female将代替1，2在结果中输出
```

__代码清单 2-6 因子的使用__

```r
# 以向量形式输入数据
patientID <- c(1,2,3,4)
age <- c(25,34,28,52)
diabetes <- c("Type1","Type2","Type1","Type1")
status <- c("Poor","Improved","Excellent","Poor")
# 分别做因子和有序因子
diabetes <- factor(diabetes)
status <- factor(status,order=TRUE)
# 合并数据框
patientdata <- data.frame(patientID,age,diabetes,status)
str(patientdata) # str()会显示对象的信息
summary(patientdata) # summary()会显示连续性变量的最值，均值，四分位数；会显示分类变量的频数值
```

#### 2.2.6 列表

可将其他数据结构整合到一个对象下

__代码清单 2-7 创建一个列表__

```R
g <- "my First List"
h <- c(25,26,18,39)
j <- matrix(1:10,nrow=5)
k <- c("one","two","three")
mylist <- list(title=g,ages=h,j,k) # title，ages分别为对象命名
mylist
# 双重括号指明数字或名称来访问列表中的元素
mylist[[2]]
mylist[["ages"]]
```

==列表很重要，其一它可以以简单的方式重新组织和调用不相干的信息；其二许多函数的返回值都是以列表的形式出现的==

#### 2.2.7 tibble数据框

```R
install.packages("tibble")
library(tibble)
mtcars <- tibble(mtcars)
mtcars
```

```
|特性/类别|数据框|tibble数据框|
|::|:---:|:---:|
|字符变量转因子|会|不会
|名称中有空格|默认空格变"."|将名称放在""下|
|取子集|简化转变量|返回数据框|
```

| 特性/类别          |      数据框      |     tibble数据框      |
| ------------------ | :--------------: | :-------------------: |
| 字符变量转因子[^1] |                  | (4.0.0以前会)现在不会 |
| 名称中有空格       |  默认空格变"."   |    将名称放在""下     |
| 取子集             | 简化子集转为变量 |    子集返回数据框     |

### 2.3 数据的数据

#### 2.3.1 键盘数据

##### 内置文本编辑器

```R
mydata <- data.frame(age=numeric(0),gender=character(0),
                    weight=numeric(0)) 
### age=numeric(0)是创建一个数值型但不含实际数据的变量
### gender=character(0)是创建一个字符型但不含实际数据的变量
### 切记逗号，而且要英文版
mydata <- edit(mydata) # 执行语句后会出现R内置文本编辑器，可以用键盘输入数据
### 在编辑器中点击列名可以更改名称和数据类型，也可以点击未命名的列名来添加列
mydata # 展示经过输入数据之后的数据框
### 再次执行mydata <- edit(mydata)，就能够编辑已经输入的数据且再输入新数据
### mydata <- edit(mydata)等价于fix(mydata)
```

##### 在代码中嵌入数据

```R
mydatatxt <- "
age gender weight
25 m 166
30 f 115
18 f 120
"
mydata <- read.table(header=TRUE,text=mydatatext) # 将字符型变量处理并返回数据框
mydata
str(mydata) # mydata确实是数据框
```

**结束RStudio程序，按Ctrl+q**

#### 2.3.2 带分隔符的文本文件导入数据

```R
mydataframe <- read.table(file,options)
### file是带分隔符的ASCⅠⅠ的文件
### options是控制处理数据的选项
```

**read.table()的选项**

```R
header						# 一个表示文件是否在第一行包含了变量名的逻辑型变量
sep							# 分开数据值的分隔符。默认是sep=" ",这表示一个或多个空格、制表符、								换行或回车。使用sep=","来读取使用逗号来分割行内数据的文件，使用								  sep="\t"来读取使用制表符来分割行内数据的文件
row.names					# 一个用于指定一个或多个行标记符的可选参数
col.names
na.strings
colClasses
quote
skip
stringAsFactors
text
```

# 第二部分 基本方法

- 第六章：单个变量可视化的方法。介绍分类变量和数值型变量的图形可视化。
- 第七章：单变量和双变量的统计方法。介绍频数分布表和列联表；及描述两变量关系的方法

# 第三部分 中级方法

- 第八章：使用回归模型对结果变量和自变量之间进行建模。包括拟合、评价模型等[^2]
- 第九章：基于方差分析及其变体对基本实验和准实验设计的分析。处理方式的组合及不同条件对数值型结果的影响。及函数在方差分析等中的用法[^2]
- 第十章：功效分析，判断样本量对结果效果是否重要。利用函数判断：在给定置信度的前提下，需要多少样本才能判断处理效果
- 第十一章：绘制图形来可视化两个或多个变量间的关系。
- 第十二章：适用于复杂情况的数据[^3]。介绍重抽法和自助法

# 第四部分 高级方法

- 第十三章：扩展八章中的回归方法到非参数方法，适用非正态分布的数据。介绍因变量为分布变量或计数型变量
- 第十四章：介绍探究和简化高维度变量的方法：主成分分析[^4]和因子分析[^5]
- 第十五章：介绍对时间序列数据的分析和预测[^6]。描述时间序列数据的一般特性之后，介绍指数预测模型和 ARIMA 预测模型
- 第十六章：介绍聚类分析即吧多个观测值组合成聚类簇从而简化多元数据
- 第十七章：介绍通过一组自变量预测案例的分类。及评估分类效率的方法
- 第十八章：存在缺失值的数据处理办法

# 第五部分 技能扩展

- 第十九章：使用 ggplot2 创建自定义图形
- 第二十章：回顾 R 语言。讨论 R 面向对象编程特性、与环境的交互和高阶函数的编写
- 第二十章：用 R 撰写报告
- 第二十一张：编写自己的包

**基本操作**

```R
getwd()	#当前工作路径
setwd(dir = "c:/Users/15303/Desktop/Rdata/")	#设置工作路径，必须有Rdata这个文件夹，没有需要创建；路径/分割
setwd(dir = "c:/Users/15303/Desktop/")	#设置桌面为工作路径

list.files()	#展示当前路径下文件
dir()	#功能同上

x <- 3	#赋值；局部变量
y <<- 5	#赋值；全局变量

ls()	#显示当前目录所有变量
ls.str()	#显示当前目录所有变量、变量类型、变量赋值
str(x)	#x变量类型及其赋值
ls(all.names = TRUE)	#显示包括隐藏文件

rm(x)	#删除x变量
rm(list=ls())	#删除所有变量

history()	#历史代码？
history(5)	#最近5条代码？
```

**R包安装**

~~~R
install.packages(vcd)	#vcd被当成变量
install.packages("vcd")	#“vcd”是字符串
install.packages(c("AER","ca"))	#同时安装多个包
update.packages()	#更行安装的包

library()	#展示安装的所有包
.libPaths()	#展示包的管理路径；前面必须有.
~~~

**R包使用**

~~~R
library(vcd)	#载入包
require(vcd)	#同上
detach("package:vcd")	#从内存中解放vcd包，要用再加载

help(package="vcd")	#查看帮助文档；也可以不加“”，因为已经下载了包
help(package="ggplot2")
library(help="vcd")	#脚本界面展示基本信息
library(help=vcd)
help(package=ggplot2)	#不加“”
help(package=vcd)

ls(package="vcd")	#FALSE；ls中没有package这个参数
ls(package=vcd)	#FALSE；ls中没有package这个参数，不论是否为字符串
ls("package:vcd")	#展示Vcd中的函数
data("package=vcd")	#FALSE；data中有package这个参数
data(package="vcd")	#展示vcd中的数据集

installed.packages()	#展示所有安装的包及附加信息
installed.packages()[,1]	#提取包名

#从一台计算机复制所有包到另一台计算机，用循环遍历下载
Rpack <- installed.packages()[,1]	
save(Rpack,file="Rpack.Rdata")
load(file="Rpack.Rdata")
for (i in Rpack) install.packages(i)
~~~

**帮助**

~~~R
help(sum)	#函数详细帮助文档
?sum	#同上
args(sum)	#只列出功能，同Tab
help(package=ggplot2)	#包帮助文档
example("mean")	#函数举例
example("hist")	#图形包举例
demo("graphics")	#举例同上

###
vignette("vcd")	#更详细
??ggplot2	#不需要“”
help.search("heatmap")
apropos("sum")	#直接列出所有功能，无用法
apropos("sum",mod="function")	#同上
RSiteSearch("sum")	#网络查找
###
~~~

**内置数据集**

~~~R
help(package="datasets")	#通过帮助文档展示数据集
data()	#展示许多数据集
data(package="MASS")	#展示R包的数据集
data(package=.packages(all.available = TRUE))	#展示所有数据集
data(Chile,package = "car")	#老师演示，现在找不到该数据集
chile	#不加载包，只加载数据集
~~~

**数据结构**

数值型、字符串型、逻辑型、日期型

向量

~~~R
c(1,2,'ada') #输出："1","2","ada"；都变成字符串型
#向量里的元素必须统一类型
x <- c(1,2,3,4,5)
mode(x)	#数字型而不是向量型
y <- "aada"
mode(y)	#字符串型
rep(x,c(1,2,1,2,1))	#x每个元素循环对应次数
x*2+c(1,2,1,2,1)	#x每个元素的2倍加上每个对应的元素

c(1:100)	#从1到100，输出100个数
seq(from=1,to=100)	#同上
seq(from=1,to=100,by=4)	#以4为间隔的等差数列
seq(from=1,to=100,by=4,length.out=10)	#参数过多失败
seq(from=1,to=100,length.out=10)	#输出10个数

rep(2,5)	#2重复5次
rep(2,time=5)	#功能同上
rep(c(2,4,6),time=5)	#向量重复5次
rep(c(2,4,6),each=5)	#每个元素重复5次
rep(c(2,4,6),each=5,time=2)	#每个元素重复5次后整体再来一遍
rep(c(2,4,6),time=2,each=5)	#同上
~~~

**向量索引**

~~~R
x <- c(1:100)
length(x)
x[1]	#第一个数；R以1为第一个数，而非0
x[0]	#integer(0)，啥也没有
x[-19]	#除第19个外，其他都输出
x[c(4:18)]	#输出4-18个数
x[c(1,4,5,6,66)]	#输出索引位置的数
x[c(1,1,12,45,66,77,45)]	#索引可以改变顺序
x[c(-2,3,5)]	#失败，不能不输出第二个又要输出第三个第五个

y <- c(1:10)
y[c(T,F,T,F,F,T)]	#以这六个去y里匹配，匹配完了再来一遍
y[c(T,F,T,F,F,T,T,T,F,T)]	#一一对应的去匹配输出
y[c(T)]	#全部输出
y[c(F)]	#全部不输出
y[c(T,F)]	#以这俩去y里匹配，分别输出不输出
y[c(T,F,F)]	#同理
y[c(T,F,T,F,F,T,T,T,F,T,T)]	#多一个输出为NA
y[y>5]	#可以用判断
y[y>5 & y<9]

z <- c("one","two",'three','four','five')
"one" %in% z	#输出为TRUE
z["one" %in% z]	#相当于z[TRUE]
z[z %in% c("one","two")]	#输出为ONE，TWO
z %in% c("one","two")	#T，T，F，F，F
k <- z %in% c("one","two")
z[k]

names(y) <- c("one","two","three","four","five",'six','seven','eight','night','ten')	#函数相当于键值对，必须对应到y的个数
euro	#键值对数据集
euro["ATS"]	#输入键输出值
y["one"]	#同上

x[101] <- 101	#给x增加一位
v <- 1:3
v[c(4:6)] <- 4:6	#给v增加4-6位置的数
v[20] <- 4	#第7-第19全是NA
append(x=v,values=99,after=5)	#在第5位后面加上一个99
append(x=v,values=99,after=0)	#在第1位前面加上一个99
y[-c(1:3)]	#不输出1-3位
y <- y[-c(1:3)]	#赋值给y
~~~

**向量运算**

~~~R
x<- 1:10
x+1	#对每个元素都加
x-3	#同上
x <- x+1	#给x赋值
y <- seq(from=1,to=100,length.out=10)
x+y	#x，y一一对应的加

x**y	#指数
x%%y	#取余
x %/% y	#取整

z <- c(1,2)
x+z	#x和z每两个加一次
x*z	#同上
z <- 1:3
x*z	#失败；由此可知长向量必须是短向量的倍数

x > 5	#返回逻辑值
x > y	#同上
c(1:3) %in% c(1:6)	#同上
x == y	#判断同上
x = y	#赋值

x <- -5:5
abs(x)	#绝对值
sqrt(x)	#开方
sqrt(25)
log(16,base=2)	#取对数
log(16)	#自然底数
log10(10)	#1

ves<-1:100
sum(ves)
max(ves)
min(ves)
range(ves)	#1，100；输出最小数和最大数
mean(ves)
var(ves)	#方差
round(var(ves),digits=2)	#取小数

t <- c(10:1)
which.max(t)	#以下都输出索引
which.min(t)
which(t==7)
which(t>5)
~~~

[^1]:使用read.table()，data.frame()，as.data.frame()
[^2]: 线性模型要求自变量连续，且符合正态分布
[^3]: 数据来源于未知或混合分布、小样本问题、异常值，或其他难处理的情况
[^4]: 将大量的相关变量转化为一组较少的不相关的复合变量
[^5]: 在一组给定的变量中发现潜在的数据结构
[^6]: 分析师通常要理解事物趋势和预测未来事件

