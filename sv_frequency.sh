#!/bin/bash
#http://hgdownload.cse.ucsc.edu/goldenpath/hg19/liftOver/
#ftp://gsapubftp-anonymous@ftp.broadinstitute.org/Liftover_Chain_Files/b37tohg19.chain

#java -jar /cluster/apps/software/picard.jar LiftoverVcf \
#     I=../input/gnomad_v2_sv.sites.vcf.gz \
#     O=../input/gnomad_v2_sv.hg19.vcf.gz \
#     CHAIN=../input/b37tohg19.chain \
#     REJECT=../input/gnomad_v2_sv.hg19.reject.vcf.gz \
#     R=/cluster/apps/refseq/GATK3/gatk3.8_hg19/ucsc.hg19.fasta VALIDATION_STRINGENCY=SILENT #LENIENT

# ../input/gnomad_v2_sv.sites.bed | sed 1d > ../input/gnomad_v2_sv.sites.col123.bed

#../software/liftOver.dms -bedPlus=4 ../input/gnomad_v2_sv.sites.bed ../input/b37tohg19.chain ../input/gnomad_v2_sv.sites.hg19.bed ../input/gnomad_v2_sv.sites.hg19.unlifted.bed 
#../software/liftOver.dms -bedPlus=4 ../input/gnomad_v2_sv.sites.hg19.bed ../input/hg19ToHg38.over.chain.gz ../input/gnomad_v2_sv.sites.hg38.bed ../input/gnomad_v2_sv.sites.hg38.unlifted.bed 

#sort -V -k1,1 -k2,2g -k3,3g ../input/gnomad_v2_sv.sites.hg38.bed > ../input/gnomad_v2_sv.sites.hg38.sorted.bed
#bgzip -f ../input/gnomad_v2_sv.sites.hg38.sorted.bed
tabix -p bed ../input/gnomad_v2_sv.sites.hg38.sorted.bed.gz

