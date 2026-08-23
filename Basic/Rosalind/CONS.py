import sys

with open(sys.argv[1], "r") as FR:
	fr = FR.read()

string = "".join(fr.split(">")[1].split("\n")[1:])

A = [0] * len(string)
C = [0] * len(string)
G = [0] * len(string)
T = [0] * len(string)

out = ""

for p in fr.split(">")[1:]:
	o = p.split("\n")[1:]
	i = "".join(o)
	for j in range(len(string)):
		if i[j] == "A":
			A[j] += 1
		elif i[j] == "C":
			C[j] += 1
		elif i[j] == "G":
			G[j] += 1
		else:
			T[j] += 1

for k in range(len(string)):
	m = A[k]
	n = "A"
	if m < C[k]:
		m = C[k]
		n = "C"
	if m < G[k]:
		m = G[k]
		n = "G"
	if m < T[k]:
		m = T[k]
		n = "T"
	out += n

print(out)
print("A: "+" ".join(str(x) for x in A))
print("C: "+" ".join(str(x) for x in C))
print("G: "+" ".join(str(x) for x in G))
print("T: "+" ".join(str(x) for x in T))