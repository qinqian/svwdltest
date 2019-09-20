#!/bin/bash -ex

rm ../input/all_s394g01018_bam.txt
while read line; do
    if [ -s /cluster/home/data_share/seq-data/raw-data/DRAGEN_BAM/${line}_DRAGEN.bam ];then 
       echo -e "$line\t/cluster/home/data_share/seq-data/raw-data/DRAGEN_BAM/${line}_DRAGEN.bam" >> ../input/all_s394g01018_bam.txt
    fi
done < <(grep 'YAOMING/s394g01018' ../input/Blood_SampleList.txt| cut -f 1)

