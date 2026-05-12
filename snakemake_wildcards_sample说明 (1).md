# Snakemake 中 `wildcards.sample` 的理解说明

## 1. 先记住一句话

`wildcards.sample` 的意思是：

> 当前 Snakemake 正在处理的样本名。

比如当前要生成：

```text
result/WR241371D.bam
```

那么：

```python
wildcards.sample
```

就等于：

```text
WR241371D
```

如果当前要生成：

```text
result/WR241372D.bam
```

那么：

```python
wildcards.sample
```

就等于：

```text
WR241372D
```

---

## 2. `wildcards.sample` 是从哪里来的？

它来自规则中的 `{sample}`。

例如：

```python
rule mapping:
    output:
        "result/{sample}.bam"
```

这里的 `{sample}` 就是一个通配符。

Snakemake 看到：

```python
"result/{sample}.bam"
```

就会自动创建一个变量：

```python
wildcards.sample
```

所以：

```python
{sample}
```

和：

```python
wildcards.sample
```

本质上表示同一个东西，都是“样本名”。

---

## 3. 举个完整例子

假设你的 `config.yaml` 是这样：

```yaml
samples:
  WR241371D:
    R1: data/WR241371D_R1.fq.gz
    R2: data/WR241371D_R2.fq.gz
  WR241372D:
    R1: data/WR241372D_R1.fq.gz
    R2: data/WR241372D_R2.fq.gz
```

这个配置文件的意思是：

```text
WR241371D 这个样本：
  R1 文件是 data/WR241371D_R1.fq.gz
  R2 文件是 data/WR241371D_R2.fq.gz

WR241372D 这个样本：
  R1 文件是 data/WR241372D_R1.fq.gz
  R2 文件是 data/WR241372D_R2.fq.gz
```

---

## 4. Snakefile 怎么读取它？

可以这样写：

```python
configfile: "config.yaml"

SAMPLES = config["samples"]

rule all:
    input:
        expand("result/{sample}.bam", sample=SAMPLES.keys())

rule mapping:
    input:
        r1 = lambda wildcards: SAMPLES[wildcards.sample]["R1"],
        r2 = lambda wildcards: SAMPLES[wildcards.sample]["R2"]
    output:
        "result/{sample}.bam"
    shell:
        """
        echo {input.r1} {input.r2} > {output}
        """
```

---

## 5. 这段代码怎么理解？

重点是这一句：

```python
r1 = lambda wildcards: SAMPLES[wildcards.sample]["R1"]
```

可以拆开理解。

### 第一步：Snakemake 先看最终目标

如果最终目标是：

```text
result/WR241371D.bam
```

而规则输出是：

```python
"result/{sample}.bam"
```

Snakemake 就会自动判断：

```text
sample = WR241371D
```

所以：

```python
wildcards.sample
```

就等于：

```text
WR241371D
```

---

### 第二步：代入代码

原代码是：

```python
SAMPLES[wildcards.sample]["R1"]
```

当：

```python
wildcards.sample = "WR241371D"
```

就相当于：

```python
SAMPLES["WR241371D"]["R1"]
```

再根据 `config.yaml`：

```yaml
WR241371D:
  R1: data/WR241371D_R1.fq.gz
```

所以最后得到：

```text
data/WR241371D_R1.fq.gz
```

---

## 6. 再看 R2

这一句：

```python
r2 = lambda wildcards: SAMPLES[wildcards.sample]["R2"]
```

如果当前样本是：

```text
WR241371D
```

就相当于：

```python
SAMPLES["WR241371D"]["R2"]
```

最后得到：

```text
data/WR241371D_R2.fq.gz
```

---

## 7. 运行 WR241372D 时也是同样道理

如果 Snakemake 当前要生成：

```text
result/WR241372D.bam
```

那么：

```python
wildcards.sample
```

等于：

```text
WR241372D
```

所以：

```python
SAMPLES[wildcards.sample]["R1"]
```

等于：

```python
SAMPLES["WR241372D"]["R1"]
```

最后得到：

```text
data/WR241372D_R1.fq.gz
```

---

## 8. 为什么不能直接写死样本名？

比如你写死：

```python
r1 = SAMPLES["WR241371D"]["R1"]
```

这样只能处理一个样本：

```text
WR241371D
```

但是你的流程通常要跑很多样本：

```text
WR241371D
WR241372D
WR241373D
WR241374D
```

如果写死样本名，就没有办法自动循环处理所有样本。

所以要写成：

```python
SAMPLES[wildcards.sample]["R1"]
```

这样 Snakemake 跑哪个样本，就自动取哪个样本的 R1 文件。

---

## 9. `lambda wildcards` 是什么？

可以简单理解为：

> 等 Snakemake 确认当前样本名以后，再去配置文件里找这个样本对应的 R1/R2 文件。

因为一开始写规则的时候，Snakemake 还不知道当前处理的是哪个样本。

只有当它要生成具体文件时，比如：

```text
result/WR241371D.bam
```

它才知道：

```text
sample = WR241371D
```

所以需要用：

```python
lambda wildcards:
```

表示“运行时再根据当前样本名取文件”。

---

## 10. 不用 `wildcards.sample` 可以吗？

可以，但前提是你的文件名非常规律。

比如你的数据永远是：

```text
data/样本名_R1.fq.gz
data/样本名_R2.fq.gz
```

那么 `config.yaml` 可以简单写成：

```yaml
samples:
  - WR241371D
  - WR241372D
```

对应 Snakefile 可以写成：

```python
configfile: "config.yaml"

SAMPLES = config["samples"]

rule all:
    input:
        expand("result/{sample}.bam", sample=SAMPLES)

rule mapping:
    input:
        r1 = "data/{sample}_R1.fq.gz",
        r2 = "data/{sample}_R2.fq.gz"
    output:
        "result/{sample}.bam"
    shell:
        """
        echo {input.r1} {input.r2} > {output}
        """
```

这种情况下，不需要写：

```python
lambda wildcards
```

因为 Snakemake 可以直接通过 `{sample}` 拼出文件名。

---

## 11. 什么时候必须用 `wildcards.sample`？

当你的 R1/R2 文件名不规则时，建议用 `wildcards.sample`。

例如：

```yaml
samples:
  WR241371D:
    R1: rawdata/A001.clean.R1.fq.gz
    R2: rawdata/A001.clean.R2.fq.gz
  WR241372D:
    R1: sequencing/B_sample_read1.fq.gz
    R2: sequencing/B_sample_read2.fq.gz
```

这种情况下，文件名不能通过：

```python
"data/{sample}_R1.fq.gz"
```

自动推出来。

所以必须从配置文件里查：

```python
SAMPLES[wildcards.sample]["R1"]
SAMPLES[wildcards.sample]["R2"]
```

---

## 12. 两种推荐写法

### 写法一：文件名有规律，推荐简单写法

`config.yaml`：

```yaml
samples:
  - WR241371D
  - WR241372D
```

`Snakefile`：

```python
configfile: "config.yaml"

SAMPLES = config["samples"]

rule all:
    input:
        expand("result/{sample}.bam", sample=SAMPLES)

rule mapping:
    input:
        r1 = "data/{sample}_R1.fq.gz",
        r2 = "data/{sample}_R2.fq.gz"
    output:
        "result/{sample}.bam"
    shell:
        """
        echo {input.r1} {input.r2} > {output}
        """
```

适合这种数据：

```text
data/WR241371D_R1.fq.gz
data/WR241371D_R2.fq.gz
data/WR241372D_R1.fq.gz
data/WR241372D_R2.fq.gz
```

---

### 写法二：文件名不一定规律，推荐稳妥写法

`config.yaml`：

```yaml
samples:
  WR241371D:
    R1: data/WR241371D_R1.fq.gz
    R2: data/WR241371D_R2.fq.gz
  WR241372D:
    R1: data/WR241372D_R1.fq.gz
    R2: data/WR241372D_R2.fq.gz
```

`Snakefile`：

```python
configfile: "config.yaml"

SAMPLES = config["samples"]

rule all:
    input:
        expand("result/{sample}.bam", sample=SAMPLES.keys())

rule mapping:
    input:
        r1 = lambda wildcards: SAMPLES[wildcards.sample]["R1"],
        r2 = lambda wildcards: SAMPLES[wildcards.sample]["R2"]
    output:
        "result/{sample}.bam"
    shell:
        """
        echo {input.r1} {input.r2} > {output}
        """
```

适合这种情况：

```text
文件名不规则
不同样本路径不一样
R1/R2 不想靠规则拼接
想在 config.yaml 中明确写清楚每个文件
```

---

## 13. 最后总结

### `wildcards.sample` 是什么？

```text
当前正在运行的样本名
```

### 它从哪里来？

来自规则里的：

```python
{sample}
```

例如：

```python
output:
    "result/{sample}.bam"
```

### 它有什么用？

用来告诉 Snakemake：

```text
现在应该读取哪个样本的 R1/R2 文件
```

### 最简单理解

当输出是：

```text
result/WR241371D.bam
```

那么：

```python
wildcards.sample = "WR241371D"
```

当输出是：

```text
result/WR241372D.bam
```

那么：

```python
wildcards.sample = "WR241372D"
```

所以：

```python
SAMPLES[wildcards.sample]["R1"]
```

就是：

```text
根据当前样本名，到 config.yaml 里找到对应的 R1 文件
```

---

## 14. 建议你现在怎么写？

如果你的文件都是这种格式：

```text
data/WR241371D_R1.fq.gz
data/WR241371D_R2.fq.gz
data/WR241372D_R1.fq.gz
data/WR241372D_R2.fq.gz
```

建议用简单写法：

```yaml
samples:
  - WR241371D
  - WR241372D
```

然后 Snakefile 用：

```python
input:
    r1 = "data/{sample}_R1.fq.gz",
    r2 = "data/{sample}_R2.fq.gz"
```

如果你想在配置文件里把每个 R1/R2 都写清楚，就用稳妥写法：

```yaml
samples:
  WR241371D:
    R1: data/WR241371D_R1.fq.gz
    R2: data/WR241371D_R2.fq.gz
  WR241372D:
    R1: data/WR241372D_R1.fq.gz
    R2: data/WR241372D_R2.fq.gz
```

然后 Snakefile 用：

```python
input:
    r1 = lambda wildcards: SAMPLES[wildcards.sample]["R1"],
    r2 = lambda wildcards: SAMPLES[wildcards.sample]["R2"]
```
