**RIPSeeker** 包下 **ripSeek** 函数用法

~~~bash
Usage:

     ripSeek(bamPath, cNAME, binSize = NULL, strandType = NULL, 
             paired=FALSE, biomaRt_dataset, goAnno, exportFormat = "gff3", 
             annotateFormat = "txt", annotateType = "TSS", outDir, 
             padjMethod = "BH", logOddCutoff = 0, pvalCutoff = 1, 
             pvalAdjCutoff = 1, eFDRCutoff = 1, ...)
     
Arguments:

 bamPath:

          Either a path to all of the bam files or a list of paths to
          individual BAM files. BED and SAM files are also accepted.

   cNAME:

          An identifer pattern found in the control alignment files.
          Once specified, these files will be used as control and the
          remaining files as RIP for discriminative analysis (see
          ‘seekRIP’).

 binSize:

          Size to use for binning the read counts across each
          chromosome. If NULL, optimal bin size within a range
          (default: minBinSize=200, maxBinSize=1200) will be
          automatically selected (see ‘selectBinSize’).

strandType:

          Type of strand can be +, -, or * as in GAlignments,
          GAlignmentPairs, or GRanges (see ‘GenomicRanges’).

  paired:

          Binary to indicate whether the library is paired-end (TRUE)
          or single-end (FALSE by default) (see ‘getAlignGal’).

biomaRt_dataset:

          The dataset name used in biomaRt for retrieving genomic
          information for a given species name (see ‘annotateRIP’).

  goAnno:

          GO dataset name used for GO enrichment analysis (See
          ‘annotateRIP’).

exportFormat:

          Format to export the RIP predictions. The commonly used ones
          are GFF and BED, which can be directly imported as a track to
          a genomic viewer such as Integrative Genomic Viewer, SAVANT
          or USCSC browser.

annotateFormat:

          Format to export the annotated RIP predictions. The default
          "txt" is a tab-delimited format, recommanded for viewing in
          Excel.

annotateType:

          Type of genomic information in association with the RIP
          predictions that can be retrieved from Ensembl database
          (Default: TSS; See ‘annotateRIP’).

  outDir:

          Output directory to save the results. The output data include
          ...

padjMethod:

          Method to adjust multiple testing (Benjamini-Hocherge method
          by default).

logOddCutoff:

          Threshold for the log odd ratio of posterior for the RIP over
          the background states (See ‘seekRIP’). Only peaks with logOdd
          score _greater_ than the ‘logOddCutoff’ will be reported.
          Default: 1.

pvalCutoff:

          Threshold for the p-value for the logOdd score. Only peaks
          with p-value _less_ than the ‘pvalCutoff’ will be reported.
          Default: 1 (i.e. no cutoff).

pvalAdjCutoff:

          Threshold for the adjusted p-value for the logOdd score. Only
          peaks with adjusted p-value _less_ than the ‘pvalAdjCutoff’
          will be reported. Default: 1 (i.e. no cutoff).

eFDRCutoff:

          Threshold for the empirical false discovery rate (eFDR). Only
          peaks with eFDR _less_ than the ‘eFDRCutoff’ will be
          reported. Default: 1 (i.e. no cutoff).

     ...:

          Arguments passed to ‘mainSeek’.

Details:

     This is the main front-end function of RIPSeeker and in many cases
     the only function that users need to get RIP predictions and all
     relevant information.

Value:

     A list is returned with the following items:

mainSeekOutputRIP: A (inner) list comprising three items:

          ‘nbhGRList’: ‘GRangesList’ of the HMM trained parameters for
          each chromosome on RIP.

          ‘alignGal, alignGalFiltered’: ‘GAlignments’ objects of the
          RIP alignment outputs from ‘combineAlignGals’ and
          ‘disambiguateMultihits’, respectively. The former may contain
          multiple alignments due to the same reads whereas the latter
          contains a one-to-one mapping from read to alignment after
          disambiguating the multihits.

mainSeekOutputCTL: Same as ‘mainSeekOutputRIP’ but for the control
          library (if available).

RIPGRList: The results as ‘GRangesList’ generated from the RIP peak
          detection. Each list item represents the RIP peaks on a
          chromosome accompanied with statistical scores including
          (read) count, logOddScore, pval, pvalAdj, eFDR for the RIP
          and control (if available). Please refer to ‘seekRIP’ for
          more details.

annotatedRIPGR: If ‘annotatedRIPGR’ is TRUE, the additional genomic
          information will be retreived according to the genomic
          coordinates of the peaks in RIPGRList. The results are saved
          in this separate GRanges object as the final results that
          user will find the most useful.

Note:

     You may only want to know the expression/abundance of known
     transcripts/genes or the foldchange between two conditions. In
     that case, use ‘rulebaseRIPSeek’ and ‘computeRPKM’, respectively.
     Both singl-end and paired-end alignments are supported in these
     functions.

###
Examples:

     if(interactive()) { # need internet connection
     
     # Retrieve system files
     extdata.dir <- system.file("extdata", package="RIPSeeker") 
     
     bamFiles <- list.files(extdata.dir, ".bam$", recursive=TRUE, full.names=TRUE)
     
     bamFiles <- grep("PRC2", bamFiles, value=TRUE)
     
     cNAME <- "SRR039214"                                            # specify control name
     
     # output file directory
     outDir <- paste(getwd(), "ripSeek_example", sep="/")
     
     # Parameters setting
     binSize <- NULL                                                 # automatically determine bin size
     minBinSize <- 10000                                             # min bin size in automatic bin size selection
     maxBinSize <- 12000                                             # max bin size in automatic bin size selection
     multicore <- TRUE                                               # use multicore
     strandType <- "-"                                               # set strand type to minus strand
     
     biomart <- "ENSEMBL_MART_ENSEMBL"               # use archive to get ensembl 65
     dataset <- "mmusculus_gene_ensembl"             # mouse dataset id name 
     host <- "dec2011.archive.ensembl.org"   # use ensembl 65 for annotation
     
     goAnno <- "org.Mm.eg.db"
     
     
     ################ run main function ripSeek to predict RIP ################
     seekOut <- ripSeek(bamPath=bamFiles, cNAME=cNAME, 
                     binSize=binSize, minBinSize = minBinSize, 
                     maxBinSize = maxBinSize, strandType=strandType, 
                     outDir=outDir, silentMain=FALSE,
                     verbose=TRUE, reverseComplement=TRUE, genomeBuild="mm9",
                     biomart=biomart, host=host,
                     biomaRt_dataset = dataset,
                     goAnno = goAnno,
                     uniqueHit = TRUE, assignMultihits = TRUE, 


     ################ visualization ################
     
     viewRIP(seekOut$RIPGRList$chrX, seekOut$mainSeekOutputRIP$alignGalFiltered, 
             seekOut$mainSeekOutputCTL$alignGalFiltered, scoreType="eFDR")
     
     }

~~~

