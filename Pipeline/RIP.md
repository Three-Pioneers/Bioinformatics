## RIP



### Question

- [ ] samtools index

~~~bash
# 王道文 RIP 测序_20260604，由于索引长度过长，无法建立 bai 索引
[E::hts_idx_check_range] Region 536877267..536877401 cannot be stored in a bai index. Try using a csi index
[E::sam_index] Read 'E250146742L1C018R03903964548' with ref_name='Chr1A', ref_length=598660471, flags=99, pos=536877268 cannot be indexed
samtools index: failed to create index for "TaGW2IP1G_IP_sorted.bam": Numerical result out of range

# 建立 cai 索引
samtools index -c <sample_sorted.sam>
~~~
