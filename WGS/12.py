out = open("hehe.txt", "w")
m = 0
for i in range(13):
    a = "{:03d}".format(i+1)
    for j in range(10):
        b = "{:03d}".format(j+1)
        m += 1
        n = "{:03d}".format(m)
        out.write("mv WGS_"+a+"_R2.part_"+b+".fq.gz WGS_"+n+".R2.fq.gz \n")
        out.write("mv WGS_"+a+"_R1.part_"+b+".fq.gz WGS_"+n+".R1.fq.gz \n")