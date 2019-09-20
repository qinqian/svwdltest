#!/bin/bash -ex
vcf
#call_melt() {
#mkdir -p /cluster/home/qinqian/yangfan/phaseC_SV/dump/melt/s394g01018/${1}
#samtools depth $2 > ${1}_DRAGEN.depth
#depth=$(awk '{n+=$3} END {print n/NR}' R18056036LD01_DRAGEN.depth)
#scripts/runMELT_2.0.5_patch_hg38.sh $2 /cluster/apps/refseq/GATK/hg38/Homo_sapiens_assembly38.fasta $depth /cluster/home/qinqian/yangfan/phaseC_SV/software/MELTv2.0.5_patch /cluster/home/qinqian/yangfan/phaseC_SV/dump/melt/s394g01018/${1} 2>&1>${1}_melt.logs
#}
#
##call_melt R18056036LD01 /cluster/home/data_share/seq-data/raw-data/DRAGEN_BAM/R18056036LD01_DRAGEN.bam
#while read line; do
#   fields=($line)
#   call_melt ${fields[0]} ${fields[1]} &
#done < <(cut -f 1,2 test_bam.txt)
#wait

call_melt() {
    mkdir -p /cluster/home/qinqian/yangfan/phaseC_SV/dump/melt/DD_negative/
    depth=$(cat ../dump/melt/DD_negative/${1}.depth.mean)
    ln -s $2 /cluster/home/qinqian/yangfan/phaseC_SV/dump/melt/DD_negative/$(basename $2)
    ln -s ${2/.bam/.bai} /cluster/home/qinqian/yangfan/phaseC_SV/dump/melt/DD_negative/$(basename $2).bai
    /cluster/home/qinqian/yangfan/phaseC_SV/src/scripts/runMELT_2.0.5_patch_hg38.sh /cluster/home/qinqian/yangfan/phaseC_SV/dump/melt/DD_negative/$(basename $2) /cluster/apps/refseq/GATK/hg38/Homo_sapiens_assembly38.fasta $depth /cluster/home/qinqian/yangfan/phaseC_SV/software/MELTv2.0.5_patch /cluster/home/qinqian/yangfan/phaseC_SV/dump/melt/DD_negative/${1}_bash 2>&1>../dump/melt/${1}_melt.logs
}

# test on node2 only, node1 failed weirdly...
while read line; do
   fields=($line)
   echo ${fields[0]} ${fields[1]}
   call_melt ${fields[0]} ${fields[1]} &
done < <(cut -f 1,2 /cluster/home/qinqian/yangfan/phaseC_SV/input/bunny_BAM_DD_final.txt)
wait

