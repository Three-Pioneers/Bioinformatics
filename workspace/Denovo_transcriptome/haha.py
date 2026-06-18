import sys

with open("D2025007_R1.fq.gz", "r") as FR:
	fr = FR.read()
A = fr.split("@")[1:]
B = i.split("\n")[1]

with open("D2025007_stats.txt", "w") as FW:
	for i in range(150):
		A = 0
		T = 0
		G = 0
		C = 0
		N = 0
		for j in B:
			if B[i] == "A":
				A = A + 1
			elif B[i] == "T":
				T = T + 1
			elif B[i] == "G":
				G = G + 1
			elif B[i] == "C":
				C = C + 1
			else:
				N = N + 1
		
		FW.write(i+1+"\t"+A+"\t"+T+"\t"+G+"\t"+C+"\t"+N+"\n")