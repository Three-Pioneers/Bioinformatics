rule MAnorm2:
	input:
		"analysis//6.DiffPeak/B73_01_vs_B73_05/sample_sheet.txt"
	output:
		"analysis//6.DiffPeak/B73_01_vs_B73_05/All_diffpeak.txt",
		"analysis//6.DiffPeak/B73_01_vs_B73_05/Sig_diffpeak.txt"
	params:
		"analysis//6.DiffPeak/B73_01_vs_B73_05"
	log:
		"log/to/log"
	script:
		"""
		/data3/Data_all/script/ATAC/bin/MAnorm2.R {input} {params} 2> {log}
		"""


rule PeakAnnotation_DiffBind:
	input:
		all_file="analysis//6.DiffPeak/B73_01_vs_B73_05/All_diffpeak.txt",
		sig_file="analysis//6.DiffPeak/B73_01_vs_B73_05/Sig_diffpeak.txt",
		SampleName="B73_01_vs_B73_05",
		gtf="ref/genome.gtf"
	output:
		"analysis/6.DiffPeak/B73_32_vs_B73_43/Peakanno/B73_32_vs_B73_43_All_PeakAnno.txt",
		"analysis/6.DiffPeak/B73_32_vs_B73_43/Peakanno/B73_32_vs_B73_43_All_unannotated_seqnames.txt",
		"analysis/6.DiffPeak/B73_32_vs_B73_43/Peakanno/B73_32_vs_B73_43_Sig_PeakAnno.txt",
		"analysis/6.DiffPeak/B73_32_vs_B73_43/Peakanno/B73_32_vs_B73_43_Sig_unannotated_seqnames.txt",
		"analysis/6.DiffPeak/B73_32_vs_B73_43/Peakanno/B73_32_vs_B73_43_coverage.pdf",
		"analysis/6.DiffPeak/B73_32_vs_B73_43/Peakanno/B73_32_vs_B73_43_coverage.png",
		"analysis/6.DiffPeak/B73_32_vs_B73_43/Peakanno/B73_32_vs_B73_43_distance_to_TSS.pdf",
		"analysis/6.DiffPeak/B73_32_vs_B73_43/Peakanno/B73_32_vs_B73_43_distance_to_TSS.png",
		"analysis/6.DiffPeak/B73_32_vs_B73_43/Peakanno/B73_32_vs_B73_43_peakHeatmap.pdf",
		"analysis/6.DiffPeak/B73_32_vs_B73_43/Peakanno/B73_32_vs_B73_43_peakHeatmap.png",
		"analysis/6.DiffPeak/B73_32_vs_B73_43/Peakanno/B73_32_vs_B73_43_pie_chart.pdf",
		"analysis/6.DiffPeak/B73_32_vs_B73_43/Peakanno/B73_32_vs_B73_43_pie_chart.png",
		"analysis/6.DiffPeak/B73_32_vs_B73_43/Peakanno/B73_32_vs_B73_43_pie_chart.txt"
	params:
		directory("analysis//6.DiffPeak/B73_01_vs_B73_05/Peakanno")
	log:
		"log/to/log"
	script:
		"""
		/data3/Data_all/script/ATAC/bin/PeakAnnotation_DiffBind.R {input.all_file} {input.sig_file} {input.SampleName} {params} {input.gtf} 2> {log}
		"""


rule GO_KEGG_Enrichment:
	input:
		Sig_genes_exprData_txt="analysis//6.DiffPeak/B73_01_vs_B73_05/Peakanno/B73_01_vs_B73_05_Sig_PeakAnno.txt",
		all_go_function="ref/Functional_annotation/2.GO/GO_function_id.txt",
		all_kegg_function="ref/Functional_annotation/3.KEGG/Enrichment_KEGG_id.txt"
	output:
		"analysis//6.DiffPeak/B73_01_vs_B73_05/GO_KEGG/Sig_GO_Enrichment.txt",
		"analysis//6.DiffPeak/B73_01_vs_B73_05/GO_KEGG/All_GO_Enrichment.txt",
		"analysis//6.DiffPeak/B73_01_vs_B73_05/GO_KEGG/GO_barplot.pdf",
		"analysis//6.DiffPeak/B73_01_vs_B73_05/GO_KEGG/GO_barplot.png",
		"analysis//6.DiffPeak/B73_01_vs_B73_05/GO_KEGG/GO_dotplot.pdf",
		"analysis//6.DiffPeak/B73_01_vs_B73_05/GO_KEGG/GO_dotplot.png",
		"analysis//6.DiffPeak/B73_01_vs_B73_05/GO_KEGG/Sig_KEGG_Enrichment.txt",
		"analysis//6.DiffPeak/B73_01_vs_B73_05/GO_KEGG/All_KEGG_Enrichment.txt",
		"analysis//6.DiffPeak/B73_01_vs_B73_05/GO_KEGG/KEGG_barplot.pdf",
		"analysis//6.DiffPeak/B73_01_vs_B73_05/GO_KEGG/KEGG_barplot.png",
		"analysis//6.DiffPeak/B73_01_vs_B73_05/GO_KEGG/KEGG_dotplot.pdf",
		"analysis//6.DiffPeak/B73_01_vs_B73_05/GO_KEGG/KEGG_dotplot.png"
	params:
		directory("analysis//6.DiffPeak/B73_01_vs_B73_05/GO_KEGG")
	log:
		"log/to/log"
	script:
		"""
		/data3/Data_all/script/ATAC/bin/GO_KEGG_Enrichment.R {input.Sig_genes_exprData_txt} {input.all_go_function} {input.all_kegg_function} {params} 2> {log}
		"""


rule pathview:
	input:
		Sig_genes_exprData_txt="analysis//6.DiffPeak/B73_01_vs_B73_05/Peakanno/B73_01_vs_B73_05_Sig_PeakAnno.txt",
		Sig_KEGG_Enrichment_txt="analysis//6.DiffPeak/B73_01_vs_B73_05/GO_KEGG/Sig_KEGG_Enrichment.txt",
		all_kegg_function_txt="ref/Functional_annotation/3.KEGG/Enrichment_KEGG_id.txt",
		gene_type="SYMBOL",
		Species="zma"
	params:
		"analysis//6.DiffPeak/B73_01_vs_B73_05/GO_KEGG/Pathway"
	log:
		"log/to/log"
	script:
		"/data3/Data_all/script/ATAC/bin/pathview.R "
		"{input.Sig_genes_exprData_txt} "
		"{input.Sig_KEGG_Enrichment_txt} "
		"{input.all_kegg_function_txt} "
		"{input.gene_type} "
		"{input.Species} "
		"{params} 2> {log}"


rule data_process:
	input:
		"analysis//6.DiffPeak/B73_01_vs_B73_05/Sig_diffpeak.txt"
	output:
		"analysis//6.DiffPeak/B73_01_vs_B73_05/FindMotif/peaks_homer.bed"
	script:
		"""
		awk 'NR>1{s=$2-1;if(s<0)s=0;print $1"\t"s"\t"$3"\tpeak_"NR-1"\t0\t+"}' {input} > {output}
		"""


rule FindMotifsGenome:
	input:
		pead_bed="analysis//6.DiffPeak/B73_01_vs_B73_05/FindMotif/peaks_homer.bed",
		genome_chr="ref/genome_chr.fa"
	output:
		"analysis/6.DiffPeak/RPC2024001_vs_WCB2024001/FindMotif/homerMotifs.all.motifs",
		"analysis/6.DiffPeak/RPC2024001_vs_WCB2024001/FindMotif/homerResults",
		"analysis/6.DiffPeak/RPC2024001_vs_WCB2024001/FindMotif/homerMotifs.motifs8",
		"analysis/6.DiffPeak/RPC2024001_vs_WCB2024001/FindMotif/homerMotifs.motifs10",
		"analysis/6.DiffPeak/RPC2024001_vs_WCB2024001/FindMotif/homerMotifs.motifs12",
		"analysis/6.DiffPeak/RPC2024001_vs_WCB2024001/FindMotif/homerResults.html",
		"analysis/6.DiffPeak/RPC2024001_vs_WCB2024001/FindMotif/knownResults",
		"analysis/6.DiffPeak/RPC2024001_vs_WCB2024001/FindMotif/knownResults.html",
		"analysis/6.DiffPeak/RPC2024001_vs_WCB2024001/FindMotif/knownResults.txt",
		"analysis/6.DiffPeak/RPC2024001_vs_WCB2024001/FindMotif/motifFindingParameters.txt",
		"analysis/6.DiffPeak/RPC2024001_vs_WCB2024001/FindMotif/nonRedundant.motifs",
		"analysis/6.DiffPeak/RPC2024001_vs_WCB2024001/FindMotif/peaks_homer.bed",
		"analysis/6.DiffPeak/RPC2024001_vs_WCB2024001/FindMotif/seq.autonorm.tsv"
	params:
		"analysis//6.DiffPeak/B73_01_vs_B73_05/FindMotif"
	log:
		"log/to/log"
	script:
		"/data3/Data_all/Software/miniconda3/bin/findMotifsGenome.pl "
		"{input.peak_bed} "
		"{input.genome_chr} "
		"-len 8,10,12 "
		"-size 200 "
		"2> {log}"