#!/bin/bash -ex
#ls /cluster/home/data_share/seq-data/raw-data/DRAGEN_SV/*/results/variants/diploid*gz /cluster/home/data_share/seq-data/raw-data/DRAGEN_SV/*/variants/diplo*vcf.gz >  ../input/all_DRAGAN_manta.txt
#mkdir ../dump/dragon/manta/
#
#while read line;do
#    base=$(echo $line | cut -d/ -f 8 )
#    echo $base
#    zcat $line | sed -e "s/SM0/${base}/g" | sed -e "s/R18054605LD01-17Y082M/R18054605LD01/g" | sed -e "s/R18054606LD01-17Y082B/R18054606LD01/g" - > ../dump/dragon/manta/${base}.vcf
#done <../input/all_DRAGAN_manta.txt
#
#ls /cluster/home/qinqian/yangfan/phaseC_SV/dump/dragon/manta/*vcf > ../input/all_DRAGAN_manta_vcf.txt

#cd wdls
#java -jar ../../software/wdltool-0.14.jar validate 01_pesr_clustering_single_algorithm_local_manta.wdl
#java -jar ../../software/wdltool-0.14.jar inputs 01_pesr_clustering_single_algorithm_local_manta.wdl > cluster.json
#python ../scripts/render_json_inputs.py -json cluster.json -tab /cluster/home/qinqian/yangfan/phaseC_SV/input/all_DRAGAN_manta_vcf.txt -contig /cluster/home/qinqian/yangfan/phaseC_SV/input/hg38_contig_list.txt -cluster
#java -Dconfig.file=../cluster/pbs_q1.conf -jar ../../software/cromwell-42.jar run 01_pesr_clustering_single_algorithm_local_manta.wdl --inputs cluster.json.filled

#rm -f ../input/evidence_dragon.txt
#while read line;do
#    base=$(echo $line | cut -d/ -f 8 )
#    batch=$(grep $base /cluster/home/luyulan/project/Combined_Pipeline/data/Blood_SampleList.txt | cut -f 10 | cut -f 2 -d /)
#
#    if [[ -s /cluster/home/luyulan/project/Combined_Pipeline/data/YAOMING/${batch}_WGS/${base}/${base}_DRAGEN_hg38.vcf.gz ]] && [[ -s /cluster/home/data_share/seq-data/raw-data/DRAGEN_BAM/${base}_DRAGEN.bam ]]; then
#        echo -e "${base}\t`ls /cluster/home/data_share/seq-data/raw-data/DRAGEN_BAM/${base}_DRAG*bam | cut -f 1 -d" "`\t`ls /cluster/home/data_share/seq-data/raw-data/DRAGEN_BAM/${base}_DRAGEN.bam.bai | cut -f 1 -d" "`\t`ls /cluster/home/luyulan/project/Combined_Pipeline/data/YAOMING/${batch}_WGS/${base}/${base}_DRAGEN_hg38.vcf.gz`" >> ../input/evidence_dragon.txt
#    fi
#done <../input/all_DRAGAN_manta.txt

#cd wdls
#java -jar ../../software/wdltool-0.14.jar validate collect_evidence_dragon.wdl
#java -jar ../../software/wdltool-0.14.jar inputs collect_evidence_dragon.wdl > collect_evidence_dragon.json
#
#python ../scripts/render_json_inputs.py -json collect_evidence_dragon.json -tab /cluster/home/qinqian/yangfan/phaseC_SV/input/evidence_dragon.txt -contig /cluster/home/qinqian/yangfan/phaseC_SV/input/hg38_contig_list.txt -baf
#java -Dconfig.file=../cluster/pbs_q2.conf -jar ../../software/cromwell-42.jar run collect_evidence_dragon.wdl --inputs collect_evidence_dragon.json.filled
#cd -

#cd wdls
#java -jar ../../software/wdltool-0.14.jar validate bincov.wdl
#java -jar ../../software/wdltool-0.14.jar inputs bincov.wdl > bincov_dragen.json
#python ../scripts/render_json_inputs.py -json bincov_dragen.json -tab /cluster/home/qinqian/yangfan/phaseC_SV/input/evidence_dragon.txt -contig /cluster/home/qinqian/yangfan/phaseC_SV/input/hg38_contig_list.txt -bincov
#java -Dconfig.file=../cluster/pbs_q1.conf -jar ../../software/cromwell-42.jar run bincov.wdl --inputs bincov_dragen.json.filled
#cd -


rm ../input/dragen_raw.makeMatrix_input.txt
while read ID; do
  echo $ID
  zcat ../dump/cnmops/s394g01018_2/${ID}/chr*raw*bed.gz | \
  bedtools intersect -f 1.0 -r -wa -a - \
  -b ../input/WGD_scoring_mask.6F_adjusted.100bp.hg19tohg38.bed > \
  ../dump/cnmops/s394g01018_2/${ID}_raw_matrix.bed
  echo -e "${ID}\t../dump/cnmops/s394g01018_2/${ID}_raw_matrix.bed" >> raw.makeMatrix_input.txt
done < <(cut -f 1 ../input/test_s394g01018_batch_bam.txt)
    #../software/WGD/bin/makeMatrix.sh -z \
    #   -o ../dump/cnmops/raw.makeMatrix.bed \
    #   -r ../input/WGD_scoring_mask.6F_adjusted.100bp.hg19tohg38.bed \
    #    raw.makeMatrix_input.txt
cd wdls
#java -jar ../../software/wdltool-0.14.jar validate 02_aggregate_local_manta.wdl
#java -jar ../../software/wdltool-0.14.jar inputs  02_aggregate_local_manta.wdl > 02_aggregate_dragen.json
java -jar ../../software/cromwell-42.jar run 02_aggregate_local_manta.wdl --inputs 02_aggregate_dragen.json
cd -
