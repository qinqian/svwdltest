#!/bin/bash -ex

zcat /cluster/home/data_share/seq-data/raw-data/DRAGEN_SV/R18055981LD01/results/variants/candidateSV.vcf.gz > 18F05482.vcf
raw_vcf=18F05482.vcf
algorithm=manta
group=1
echo svtk standardize --prefix ${algorithm}_${group}_standard --contigs /cluster/apps/refseq/GATK/hg38/Homo_sapiens_assembly38.fasta.fai ${raw_vcf} ${algorithm}.${group}_standard.vcf ${algorithm}
svtk standardize --prefix ${algorithm}_${group}_standard --contigs /cluster/apps/refseq/GATK/hg38/Homo_sapiens_assembly38.fasta.fai ${raw_vcf} ${algorithm}.${group}_standard.vcf ${algorithm}
#svtk annotate \
#      --gencode /cluster/home/lzx/SV/SV_PhenoPro/ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_30/gencode.v30.annotation.gtf.gz \
#      ${algorithm}.${group}.vcf \
#      ${algorithm}.${group}_annotate.vcf
#      dump/delly/P18016745LD01-17F05750_standard_annotate.vcf
