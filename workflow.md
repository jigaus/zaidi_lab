# RNAseq workflow for RZL May 2024 Data
  below is the general directory tree i set up. i had a "mapped_##" directory for each sample (mapped_01, mapped_02, etc...). 
```bash
rnaseq #general RNAseq folder
`-- data
    |-- bam 
    |-- counts 
    |-- index 
    |-- mapped_01 
    |-- ...
    |-- raw 
    `-- ref
```
## quality control/trimming
carried out by Novogene (existing QC reports)

## sequence alignment
aligned to human genome GRCh38/hg38 by STAR. i mostly followed a tutorial for this, so my settings were probably fairly basic.

 genome index (generate_index.sh):
  ```bash
    #/bin/bash
    
    STAR --runThreadN 8 \
    --runMode genomeGenerate \
    --genomeDir ~/rnaseq/data/index \
    --genomeFastaFiles ~/rnaseq/data/ref/ch38_fasta.fa \
    --sjdbGTFfile ~/rnaseq/data/ref/ch38_gtf.gtf \
    --genomeSAindexNbases 12 \
  ```
script to map reads (map_reads.sh). i submitted this as a job to temple's batch system, hence the length of the paths. example output can be seen in the ".final.out" file:
```bash
#!/bin/bash

STAR --runThreadN 16 \
--readFilesIn /home/tul64815/rnaseq/data/raw/RZL11_1.fq /home/tul64815/rnaseq/data/raw/RZL11_2.fq \
--genomeDir /home/tul64815/rnaseq/data/index \
--outSAMtype BAM SortedByCoordinate \
--quantMode GeneCounts \
--outFileNamePrefix /home/tul64815/rnaseq/data/mapped_11/RZL11
```
i think i read somewhere that you needed the transcriptomeSAM output option for use in RSEM, which is what i would've liked to have used to count the reads; however, by the time i learned that, it was after i aligned everything. if it ends up being that i should just use RSEM no matter what, i'll go back and realign...

## counting
done with featureCounts. initially, i did this via Linux...
```bash
#!/bin/bash

featureCounts \
-T 16 \
-p \
-M \
--countReadPairs \
-t exon \
-g gene_id \
-a ~/rnaseq/data/ref/ch38_gtf.gtf \
-o ~/rnaseq/data/counts/RZL.counts \
bam/*.bam
```
which ended up being fine. but after looking into how i could generate a count matrix for differential expression analysis (via DESeq2), i realized it would've been easier to just do it in R:
```R
files <- c("RZL01Aligned.sortedByCoord.out.bam", "RZL02Aligned.sortedByCoord.out.bam",
          "RZL03Aligned.sortedByCoord.out.bam", "RZL04Aligned.sortedByCoord.out.bam",
          "RZL05Aligned.sortedByCoord.out.bam", "RZL06Aligned.sortedByCoord.out.bam",
          "RZL07Aligned.sortedByCoord.out.bam", "RZL08Aligned.sortedByCoord.out.bam",
          "RZL09Aligned.sortedByCoord.out.bam", "RZL10Aligned.sortedByCoord.out.bam",
          "RZL11Aligned.sortedByCoord.out.bam", "RZL12Aligned.sortedByCoord.out.bam")

counts <- featureCounts(files,
  annot.inbuilt = "hg38",
  GTF.featureType = "exon",
  GTF.attrType = "gene_id",
  nthreads = 16,
  countMultiMappingReads = TRUE,
  isPairedEnd = TRUE,
  strandSpecific = 0,
)
```
i'm getting about 65-70% alignment, which i saw some people say was okay. however, i'm still getting fairly high numbers in the "Unassigned_NoFeatures" and "Unassigned_Ambiguity" categories and i'm not sure if it's normal or not. in any case, this is where i'm at now (as of 12:07AM on 8 august 2024). my next steps will be to start diff exp. analysis.


