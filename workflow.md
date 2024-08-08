## RNAseq workflow for RZL May 2024 Data

- **quality control/trimming:** carried out by Novogene (existing QC reports)
- **sequence alignment**: aligned to human genome GRCh38/hg19 by STAR
  below is the general directory tree i set up. i had a "mapped_##" directory for each sample (mapped_01, mapped_02, etc...). i mostly followed a tutorial for this so my settings were probably fairly basic.
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
script to map reads (map_reads.sh). i submitted this as a job to temple's batch system, hence the length of the paths:
```bash
#!/bin/bash

STAR --runThreadN 16 \
--readFilesIn /home/tul64815/rnaseq/data/raw/RZL11_1.fq /home/tul64815/rnaseq/data/raw/RZL11_2.fq \
--genomeDir /home/tul64815/rnaseq/data/index \
--outSAMtype BAM SortedByCoordinate \
--quantMode GeneCounts \
--outFileNamePrefix /home/tul64815/rnaseq/data/mapped_11/RZL11
```




