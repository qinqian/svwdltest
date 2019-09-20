#!/bin/bash -ex
#https://software.broadinstitute.org/wdl/documentation/article?id=6751
#https://software.broadinstitute.org/wdl/documentation/article?id=6749
#https://software.broadinstitute.org/wdl/documentation/article?id=7158
#https://software.broadinstitute.org/wdl/documentation/article?id=7614
#https://blog.gtwang.org/linux/cromwell-pbs-professional-backend-tutorial/
##https://github.com/gatk-workflows/
##https://github.com/gatk-workflows/gatk4-mitochondria-pipeline/blob/master/mitochondria-pipeline.wdl
#conda activate vcf

svtk_run() {
   algorithm=manta
   group=1
   svtk standardize --prefix ${algorithm}_${group} --contigs ${contigs} --min-size ${min_svsize} ${raw_vcf} ${algorithm}.${group}.vcf ${algorithm}
}

manta_run() {
  mkdir -p dump/P18016745LD01-17F05750
  python2 /cluster/home/qinqian/yangfan/phaseC_SV/gnomad-sv-pipeline/manta-1.0.3.centos5_x86_64/bin/configManta.py \
  	  --bam /cluster/home/bunny/WGS/output/result/P18016745LD01-17F05750/BAM/P18016745LD01-17F05750.aligned.duplicate_marked.sorted.bam \
  	 --referenceFasta /cluster/apps/refseq/GATK/hg38/Homo_sapiens_assembly38.fasta \
  	 --runDir dump/P18016745LD01-17F05750

  python2 dump/P18016745LD01-17F05750/runWorkflow.py -j 8 -m local
}

melt_run() {
  #ls `pwd`/MELTv2.1.5/me_refs/Hg38/*zip > mei_list.txt
  ls `pwd`/MELTv2.1.5/me_refs/1KGP_Hg19/*zip > mei_list.txt
  mkdir -p dump/melt
  #test
  #java -jar MELTv2.1.5/MELT.jar Single \
  #     -c 8 \
  #     -t /cluster/home/qinqian/yangfan/phaseC_SV/gnomad-sv-pipeline/mei_list.txt \
  #     -h /cluster/home/qinqian/yangfan/phaseC_SV/gnomad-sv-pipeline/hs37d5.fa \
  #     -bamfile /cluster/home/qinqian/yangfan/phaseC_SV/gnomad-sv-pipeline/NA12878.mapped.ILLUMINA.bwa.CEU.low_coverage.20121211.bam \
  #     -n /cluster/home/qinqian/yangfan/phaseC_SV/gnomad-sv-pipeline/MELTv2.1.5/add_bed_files/1KGP_Hg19/hg19.genes.bed \
  #     -w /cluster/home/qinqian/yangfan/phaseC_SV/gnomad-sv-pipeline/dump/melt/NA12878

  #failed bowtie2 mix single and paired end reads...
  #java -jar MELTv2.1.5/MELT.jar Single \
  #     -c 40 \
  #     -t /cluster/home/qinqian/yangfan/phaseC_SV/gnomad-sv-pipeline/mei_list.txt \
  #     -h /cluster/apps/refseq/GATK/hg38/Homo_sapiens_assembly38.fasta \
  #     -bamfile /cluster/home/bunny/WGS/output/result/P18016745LD01-17F05750/BAM/P18016745LD01-17F05750.aligned.duplicate_marked.sorted.bam \
  #     -n /cluster/home/qinqian/yangfan/phaseC_SV/gnomad-sv-pipeline/MELTv2.1.5/add_bed_files/Hg38/Hg38.genes.bed \
  #     -w /cluster/home/qinqian/yangfan/phaseC_SV/gnomad-sv-pipeline/dump/melt/P18016745LD01-17F05750

  #ln -s /cluster/home/data_share/seq-data/raw-data/DRAGEN_BAM/P18016739LD01_DRAGEN.bam .
  #ln -s /cluster/home/data_share/seq-data/raw-data/DRAGEN_BAM/P18016739LD01_DRAGEN.bam.bai .
  #java -jar MELTv2.1.5/MELT.jar Single \
  #     -c 40 \
  #     -t /cluster/home/qinqian/yangfan/phaseC_SV/gnomad-sv-pipeline/mei_list.txt \
  #     -h /cluster/apps/refseq/GATK/hg38/Homo_sapiens_assembly38.fasta \
  #     -bamfile P18016739LD01_DRAGEN.bam \
  #     -n /cluster/home/qinqian/yangfan/phaseC_SV/gnomad-sv-pipeline/MELTv2.1.5/add_bed_files/Hg38/Hg38.genes.bed \
  #     -w /cluster/home/qinqian/yangfan/phaseC_SV/gnomad-sv-pipeline/dump/melt/P18016739LD01_DRAGEN_bam

  #bwa mem -t 40 /cluster/apps/refseq/GATK3/gatk3.8_hg19/ucsc.hg19.fasta /cluster/home/data_share/seq-data/raw-data/YM-WGS-01/fastq/P18016702LD01-16F6864M_R1.fastq.gz /cluster/home/data_share/seq-data/raw-data/YM-WGS-01/fastq/P18016702LD01-16F6864M_R2.fastq.gz | samtools view -bSu - | samtools sort -n - | samtools fixmate /dev/stdin /dev/stdout | samtools sort -o - | samtools fillmd -u - /cluster/apps/refseq/GATK3/gatk3.8_hg19/ucsc.hg19.fasta > fixed.bam

  #samtools index fixed.bam

  #samtools view -b -f 0x2 test.bam > mappedPairs.bam
  samtools index mappedPairs.bam
  java -jar MELTv2.1.5/MELT.jar Single \
     -c 10 \
     -t /cluster/home/qinqian/yangfan/phaseC_SV/gnomad-sv-pipeline/mei_list.txt \
     -h /cluster/apps/refseq/GATK3/gatk3.8_hg19/ucsc.hg19.fasta \
     -bamfile mappedPairs.bam \
     -n /cluster/home/qinqian/yangfan/phaseC_SV/gnomad-sv-pipeline/MELTv2.1.5/add_bed_files/1KGP_Hg19/hg19.genes.bed \
     -w /cluster/home/qinqian/yangfan/phaseC_SV/gnomad-sv-pipeline/dump/melt/P18016702LD01-16F6864M
}

delly_run() {
    delly/src/delly call -g /cluster/apps/refseq/GATK/hg38/Homo_sapiens_assembly38.fasta -o P18016745LD01-17F05750.bcf /cluster/home/bunny/WGS/output/result/P18016745LD01-17F05750/BAM/P18016745LD01-17F05750.aligned.duplicate_marked.sorted.bam 
}

annotate() {
    export TMPDIR=tmp; ## too much memory consumption

    #bcftools view dump/delly/P18016745LD01-17F05750.bcf > dump/delly/P18016745LD01-17F05750.vcf
    #svtk standardize --prefix dump/delly/P18016745LD01-17F05750_standard --contigs /cluster/apps/refseq/GATK/hg38/Homo_sapiens_assembly38.fasta.fai dump/delly/P18016745LD01-17F05750.vcf dump/delly/P18016745LD01-17F05750_standard.vcf delly

    #svtk annotate \
    #     --gencode /cluster/home/lzx/SV/SV_PhenoPro/ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_30/gencode.v30.annotation.gtf.gz \
    #     dump/delly/P18016745LD01-17F05750_standard.vcf \
    #     dump/delly/P18016745LD01-17F05750_standard_annotate.vcf
    #svtk annotate \
    #      --gencode /cluster/home/lzx/SV/SV_PhenoPro/ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_30/gencode.v30.annotation.gtf.gz \
    #      dump/delly/P18016745LD01-17F05750_4000.vcf \
    #      dump/delly/P18016745LD01-17F05750_4000_annotate.vcf
}

#delly_run
#manta_run
#melt_run
#annotate

cp_docker_broad() {
   #docker run -it -v /cluster/home/qinqian/yangfan/phaseC_SV/software:/local talkowski/sv-pipeline cp /opt/sv-pipeline/dockerfiles/melt/MELTv2.0.5_patch.tar.gz /local
   docker run -it -v /cluster/home/qinqian/yangfan/phaseC_SV/src/scripts/:/local talkowski/sv-pipeline cp /opt/sv-pipeline/dockerfiles/melt/runMELT_2.0.5_patch_hg38.sh /local
}

liftover_WGD_6F() {
    #wget -c http://hgdownload.cse.ucsc.edu/goldenpath/hg19/liftOver/hg19ToHg38.over.chain.gz
    #wget -c http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64.v369/liftOver
    rm ../input/WGD_scoring_mask.6F_adjusted.100bp.hg19tohg38.bed
    ../software/liftOver.dms ../software/WGD/refs/WGD_scoring_mask.6F_adjusted.100bp.hg19.bed ../input/hg19ToHg38.over.chain.gz ../input/WGD_scoring_mask.6F_adjusted.100bp.hg19tohg38.bed ../input/WGD_scoring_mask.6F_adjusted.100bp.hg19.unlifted.bed
    rm input/hg38_contig_list.txt

    grep -v "[-_]" /cluster/apps/refseq/GATK/hg38/Homo_sapiens_assembly38.fasta.fai | grep -v "chrEBV" | grep -v "chrM" > ../input/hg38_contig_list.txt
    
    while read line; do
        rm ../input/WGD_scoring_mask.6F_adjusted.100bp.hg19tohg38.${line}.bed.gz
        grep $line ../input/WGD_scoring_mask.6F_adjusted.100bp.hg19tohg38.bed > ../input/WGD_scoring_mask.6F_adjusted.100bp.hg19tohg38.${line}.bed
        gzip ../input/WGD_scoring_mask.6F_adjusted.100bp.hg19tohg38.${line}.bed
    done < <(cut -f 1 ../input/hg38_contig_list.txt)
  
}

call_bincov() {
    cd wdls
    java -jar ../../software/wdltool-0.14.jar validate bincov.wdl
    java -jar ../../software/wdltool-0.14.jar inputs bincov.wdl > bincov.json
    python ../scripts/render_json_inputs.py -json bincov.json -tab /cluster/home/qinqian/yangfan/phaseC_SV/input/test_s394g01018_batch_bam.txt -bincov
    #java -Dconfig.file=../cluster/pbs.conf -jar ../../software/cromwell-42.jar run bincov.wdl --inputs bincov.json.filled
    #java -jar ../../software/cromwell-42.jar run bincov.wdl --inputs bincov.json.filled
    cd - 
    #rm R18055980LD01_3.txt
    #while read contig; do
    #    raw=$(ls ../dump/cnmops/s394g01018_2/R18055980LD01/${contig}.*raw*gz)
    #    weight=$(ls ../input/WGD_scoring_mask.6F_adjusted.100bp.hg19tohg38.${contig}.bed.gz)
    #    echo -e "${contig}\t${raw}\t${raw/raw/corrected}\t${weight}" >> R18055980LD01_3.txt
    #done < <(cut -f 1 ../input/hg38_contig_list.txt | grep -v "chrM")

    # whole genome dosage model, missing 6F metadata files...
    # Rscript ../software/WGD/bin/multiCorrection.R -z R18055980LD01_3.txt#

    #rm raw.makeMatrix_input.txt
    #while read ID; do
    #  echo $ID
    #  zcat ../dump/cnmops/s394g01018_2/${ID}/chr*raw*bed.gz | \
    #  bedtools intersect -f 1.0 -r -wa -a - \
    #  -b ../input/WGD_scoring_mask.6F_adjusted.100bp.hg19tohg38.bed > \
    #  ../dump/cnmops/s394g01018_2/${ID}_raw_matrix.bed
    #  echo -e "${ID}\t../dump/cnmops/s394g01018_2/${ID}_raw_matrix.bed" >> raw.makeMatrix_input.txt
    #done < <(cut -f 1 ../input/test_s394g01018_batch_bam.txt)

    #../software/WGD/bin/makeMatrix.sh -z \
    #   -o ../dump/cnmops/raw.makeMatrix.bed \
    #   -r ../input/WGD_scoring_mask.6F_adjusted.100bp.hg19tohg38.bed \
    #    raw.makeMatrix_input.txt

    #rm raw.makeMatrix_input.txt
    #while read ID; do
    #  echo $ID
    #  zcat ../dump/cnmops/s394g01018_2/${ID}/chr*raw*bed.gz > ../dump/cnmops/s394g01018_2/${ID}_raw_matrix.bed
    #  echo -e "${ID}\t../dump/cnmops/s394g01018_2/${ID}_raw_matrix.bed" >> raw.makeMatrix_input.txt
    #done < <(cut -f 1 ../input/test_s394g01018_batch_bam.txt)
    #../software/WGD/bin/cnMOPS_workflow.sh -o ../dump/cnmops/s394g01018_2/ -p s394g01018 raw.makeMatrix_input.txt -c
}

call_melt() {
  echo 'run melt...'
  #java -jar ../software/wdltool-0.14.jar validate wdls/melt.wdl
  #java -jar ../software/wdltool-0.14.jar inputs wdls/melt.wdl > wdls/melt.json
  #python scripts/render_json_inputs.py -json wdls/melt.json -tab /cluster/home/qinqian/yangfan/phaseC_SV/input/test_s394g01018_batch_bam.txt -melt
  #tail wdls/melt.json
  #tail wdls/melt.json.filled
  ##java -jar ../software/cromwell-42.jar run wdls/melt.wdl --inputs wdls/melt.json.filled
  #java -Dconfig.file=cluster/pbs.conf -jar ../software/cromwell-42.jar run wdls/melt.wdl --inputs wdls/melt.json.filled

}

#cp_docker_broad
#liftover_WGD_6F

call_delly() {
    cd wdls
    java -jar ../../software/wdltool-0.14.jar validate delly.wdl
    java -jar ../../software/wdltool-0.14.jar inputs delly.wdl  > delly.json
    python ../scripts/render_json_inputs.py -json delly.json -tab /cluster/home/qinqian/yangfan/phaseC_SV/input/test_s394g01018_batch_bam.txt -delly
    tail delly.json.filled
    #java -Dconfig.file=../cluster/pbs.conf -jar ../../software/cromwell-42.jar run delly.wdl --inputs delly.json.filled
    java -jar ../../software/cromwell-42.jar run delly.wdl --inputs delly.json.filled
    cd -
    
}

#call_bincov
#call_delly
source ~/.bashrc
#vcf-concat ../dump/melt/s394g01018/R18055980LD01/ALU.final_comp.vcf ../dump/melt/s394g01018/R18055980LD01/SVA.final_comp.vcf ../dump/melt/s394g01018/R18055980LD01/LINE1.final_comp.vcf > ../dump/melt/s394g01018/R18055980LD01/melt.vcf
cd wdls/
#java -jar ../../software/wdltool-0.14.jar inputs 00_pesr_preprocessing.wdl > 00_pesr_preprocessing.json
#python ../scripts/render_json_inputs.py -json 00_pesr_preprocessing.json -tab /cluster/home/qinqian/yangfan/phaseC_SV/input/test_s394g01018_batch_bam.txt -process
#java -jar ../../software/cromwell-42.jar run 00_pesr_preprocessing.wdl --inputs 00_pesr_preprocessing.json.filled

echo java -jar ../../software/wdltool-0.14.jar inputs 00_batch_BAF_merging.wdl 
java -jar ../../software/wdltool-0.14.jar inputs 00_batch_BAF_merging.wdl 
#python ../scripts/render_json_inputs.py -json 00_pesr_preprocessing.json -tab /cluster/home/qinqian/yangfan/phaseC_SV/input/test_s394g01018_batch_bam.txt -process
#java -jar ../../software/cromwell-42.jar run 00_pesr_preprocessing.wdl --inputs 00_pesr_preprocessing.json.filled

echo java -jar ../../software/wdltool-0.14.jar inputs 00_batch_PESRRD_merging.wdl
java -jar ../../software/wdltool-0.14.jar inputs 00_batch_PESRRD_merging.wdl

echo java -jar ../../software/wdltool-0.14.jar inputs 00_batch_SR_merging.wdl
java -jar ../../software/wdltool-0.14.jar inputs 00_batch_SR_merging.wdl

echo java -jar ../../software/wdltool-0.14.jar inputs 00_batch_evidence_merging.wdl
java -jar ../../software/wdltool-0.14.jar inputs 00_batch_evidence_merging.wdl

echo java -jar ../../software/wdltool-0.14.jar inputs 00_depth_preprocessing.wdl
java -jar ../../software/wdltool-0.14.jar inputs 00_depth_preprocessing.wdl

cd - 

