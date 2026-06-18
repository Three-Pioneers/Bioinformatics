#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Minimal Trinity length stats:
只生成:
  - length_stats_table.txt
  - length_bins_bar.png
  - length_bins_bar.pdf

规则:
  - 统计长度 >=200 bp 的序列
  - Unigene: 对每个 gene 选最长 isoform (根据 Trinity.fasta.gene_trans_map)
"""

import argparse, gzip, os, sys, re
from collections import defaultdict, Counter

BIN_NAMES = ["200-300", "300-500", "500-1000", "1000-2000", "2000+"]

def openmaybe(path):
    return gzip.open(path, "rt") if path.endswith(".gz") else open(path, "r")

def fasta_name2len(path, min_len=200):
    d, name, L = {}, None, 0
    with openmaybe(path) as fh:
        for line in fh:
            if not line:
                continue
            if line[0] == ">":
                if name is not None and L >= min_len:
                    d[name] = L
                name = line[1:].strip().split()[0]
                L = 0
            else:
                L += len(line.strip())
        if name is not None and L >= min_len:
            d[name] = L
    return d

def parse_gene_map(path):
    # gene \t transcript (Trinity 默认)
    # 做鲁棒：若列顺序颠倒，按是否含 "_i" 猜 transcript
    gm = defaultdict(list)
    with open(path) as f:
        for ln in f:
            ln = ln.strip()
            if not ln: continue
            a = re.split(r"\s+", ln)
            if len(a) < 2: continue
            c1, c2 = a[0], a[1]
            if "_i" in c2 and "_i" not in c1:
                gene, tx = c1, c2
            elif "_i" in c1 and "_i" not in c2:
                gene, tx = c2, c1
            else:
                gene, tx = c1, c2
            gm[gene].append(tx)
    return gm

def n50(lengths):
    if not lengths: return 0
    total = sum(lengths); half = total / 2.0
    s = 0
    for L in sorted(lengths, reverse=True):
        s += L
        if s >= half: return L
    return 0

def bin_count(lengths):
    cnt = Counter()
    for L in lengths:
        if L < 300: cnt["200-300"] += 1
        elif L < 500: cnt["300-500"] += 1
        elif L < 1000: cnt["500-1000"] += 1
        elif L < 2000: cnt["1000-2000"] += 1
        else: cnt["2000+"] += 1
    for b in BIN_NAMES: cnt.setdefault(b, 0)
    return cnt

def fmt_int(n): return f"{n:,}"
def fmt_pct(a,b): return f"{(100.0*a/b if b else 0):.2f}%"
def fmt_float(x, nd=2): return f"{x:.{nd}f}"

def main():
    ap = argparse.ArgumentParser(description="Make length_stats_table.txt and bar plot from Trinity outputs")
    ap.add_argument("--fasta", required=True, help="Trinity.fasta (可为 .gz)")
    ap.add_argument("--gene_map", required=True, help="Trinity.fasta.gene_trans_map")
    ap.add_argument("--outdir", required=True, help="输出目录")
    ap.add_argument("--title", default="Transcript vs Unigene length distribution (≥200 bp)")
    ap.add_argument("--min_len", type=int, default=200)
    args = ap.parse_args()

    os.makedirs(args.outdir, exist_ok=True)

    # 所有转录本
    name2len = fasta_name2len(args.fasta, args.min_len)
    t_lengths = list(name2len.values())

    # 每基因最长 isoform
    gm = parse_gene_map(args.gene_map)
    u_lengths, missing = [], 0
    for g, txs in gm.items():
        lens = [name2len[t] for t in txs if t in name2len]
        if lens: u_lengths.append(max(lens))
        else: missing += 1

    # 统计
    t_bins, u_bins = bin_count(t_lengths), bin_count(u_lengths)
    tN, uN = len(t_lengths), len(u_lengths)
    tBP, uBP = sum(t_lengths), sum(u_lengths)
    tMean, uMean = (tBP/tN if tN else 0.0), (uBP/uN if uN else 0.0)
    tN50, uN50 = n50(t_lengths), n50(u_lengths)

    # 写 TXT（改为 \t 分隔）
    txt_path = os.path.join(args.outdir, "length_stats_table.txt")
    with open(txt_path, "w") as out:
        out.write("Length Range\tTranscript\tUnigene\n")
        for b in BIN_NAMES:
            out.write(f"{b}\t{fmt_int(t_bins[b])}({fmt_pct(t_bins[b], tN)})\t{fmt_int(u_bins[b])}({fmt_pct(u_bins[b], uN)})\n")
        out.write(f"Total Number\t{fmt_int(tN)}\t{fmt_int(uN)}\n")
        out.write(f"Total Length\t{fmt_int(tBP)}\t{fmt_int(uBP)}\n")
        out.write(f"N50 Length\t{fmt_int(tN50)}\t{fmt_int(uN50)}\n")
        out.write(f"Mean Length\t{fmt_float(tMean,2)}\t{fmt_float(uMean,2)}\n")

    # 画图
    try:
        import matplotlib
        matplotlib.use("Agg")
        import matplotlib.pyplot as plt

        labels = BIN_NAMES
        t_vals = [t_bins[b] for b in labels]
        u_vals = [u_bins[b] for b in labels]
        x = range(len(labels)); width = 0.38

        plt.figure(figsize=(8,4.6))
        plt.bar([i - width/2 for i in x], t_vals, width, label="Transcript")
        plt.bar([i + width/2 for i in x], u_vals, width, label="Unigene")
        plt.xticks(list(range(len(labels))), labels)
        plt.ylabel("Count"); plt.title(args.title); plt.legend()
        plt.tight_layout()

        png = os.path.join(args.outdir, "length_bins_bar.png")
        pdf = os.path.join(args.outdir, "length_bins_bar.pdf")
        plt.savefig(png, dpi=300); plt.savefig(pdf)
    except Exception as e:
        sys.stderr.write(f"[warn] plotting failed or matplotlib not available: {e}\n")

    sys.stderr.write("Done.\n")
    sys.stderr.write(f"  Wrote: {txt_path}\n")
    sys.stderr.write(f"  Plots: length_bins_bar.png/.pdf in {args.outdir}\n")
    if missing:
        sys.stderr.write(f"  Note : {missing} gene(s) in gene_trans_map had no >= {args.min_len} bp transcript in FASTA.\n")

if __name__ == "__main__":
    main()
