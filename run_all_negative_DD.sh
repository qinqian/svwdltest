#!/bin/bash 

get_meta() {
rm -f ../input/bunny_BAM_DD.txt
while read line; do
   fields=(${line})
   bam=$(grep ${fields[0]}- ../input/bunny_new_list.txt | cut -f 2)
   grep ${fields[0]}- ../input/bunny_new_list.txt | awk -v batch="${fields[3]}" -v bai=${bam/.bam/.bai} -v gender=${fields[2]} -v sample="${fields[1]}" '{printf("%s\t%s\t%s\t%s\t%s\t%s\t%s\n",$1,$2,bai,batch,gender,sample,$3)}' >> ../input/bunny_BAM_DD.txt
done < <(grep -v "NA" ../input/BAM_done_DD_BSL.txt | awk '{OFS=" ";print $1,$2,$7,$8}')
grep -v "NA" ../input/bunny_BAM_DD.txt > ../input/bunny_BAM_DD_final.txt
grep -v "[-_]" /cluster/apps/refseq/GATK/hg38/Homo_sapiens_assembly38.fasta.fai | grep -v "chrEBV" | grep -v "chrM" > ../input/hg38_contig_list.txt
}

run_bincov() {
cd wdls
java -jar ../../software/wdltool-0.14.jar validate bincov.wdl
java -jar ../../software/wdltool-0.14.jar inputs bincov.wdl > bincov_DD.json
python ../scripts/render_json_inputs.py -json bincov_DD.json -tab /cluster/home/qinqian/yangfan/phaseC_SV/input/bunny_BAM_DD_final.txt -contig /cluster/home/qinqian/yangfan/phaseC_SV/input/hg38_contig_list.txt -bincov
java -Dconfig.file=../cluster/pbs.conf -jar ../../software/cromwell-42.jar run bincov.wdl --inputs bincov_DD.json.filled
cd - 
}

run_delly() {
cd wdls
java -jar ../../software/wdltool-0.14.jar validate delly.wdl
java -jar ../../software/wdltool-0.14.jar inputs delly.wdl > delly_DD.json
python ../scripts/render_json_inputs.py -json delly_DD.json -tab /cluster/home/qinqian/yangfan/phaseC_SV/input/bunny_BAM_DD_final.txt -contig /cluster/home/qinqian/yangfan/phaseC_SV/input/hg38_contig_list.txt -delly
java -Dconfig.file=../cluster/pbs_q1.conf -jar ../../software/cromwell-42.jar run delly.wdl --inputs delly_DD.json.filled
cd - 
}

run_manta() {
rm ../input/bunny_BAM_DD_final_left.txt
for i in P18020639LD01-18F00534 P18020723LD01-18F01729 R18044760LD01-17F01073 R18044841LD01-17F02144 R18045505LD01-17F02370;do
    grep $i ../input/bunny_BAM_DD_final.txt >> ../input/bunny_BAM_DD_final_left.txt
done

cd wdls
java -jar ../../software/wdltool-0.14.jar validate manta.wdl
java -jar ../../software/wdltool-0.14.jar inputs manta.wdl > manta_DD.json
#python ../scripts/render_json_inputs.py -json manta_DD.json -tab /cluster/home/qinqian/yangfan/phaseC_SV/input/bunny_BAM_DD_final.txt -contig /cluster/home/qinqian/yangfan/phaseC_SV/input/hg38_contig_list.txt -manta
python ../scripts/render_json_inputs.py -json manta_DD.json -tab /cluster/home/qinqian/yangfan/phaseC_SV/input/bunny_BAM_DD_final_left.txt -contig /cluster/home/qinqian/yangfan/phaseC_SV/input/hg38_contig_list.txt -manta
java -Dconfig.file=../cluster/pbs_q1_cpu20.conf -jar ../../software/cromwell-42.jar run manta.wdl --inputs manta_DD.json.filled
cd - 
}

run_melt() {
cd wdls
## calculate coverage per base
# java -jar ../../software/wdltool-0.14.jar validate depth.wdl
# java -jar ../../software/wdltool-0.14.jar inputs depth.wdl > depth_DD.json
# python ../scripts/render_json_inputs.py -json depth_DD.json -tab /cluster/home/qinqian/yangfan/phaseC_SV/input/bunny_BAM_DD_final.txt -contig /cluster/home/qinqian/yangfan/phaseC_SV/input/hg38_contig_list.txt -depth
# java -Dconfig.file=../cluster/pbs_q1.conf -jar ../../software/cromwell-42.jar run depth.wdl --inputs depth_DD.json.filled

## depends on the depth calculation
java -jar ../../software/wdltool-0.14.jar validate melt.wdl
java -jar ../../software/wdltool-0.14.jar inputs melt.wdl > melt_DD.json
python ../scripts/render_json_inputs.py -json melt_DD.json -tab /cluster/home/qinqian/yangfan/phaseC_SV/input/bunny_BAM_DD_final.txt -contig /cluster/home/qinqian/yangfan/phaseC_SV/input/hg38_contig_list.txt -melt
#java -Dconfig.file=../cluster/pbs_q1.conf -jar ../../software/cromwell-42.jar run melt.wdl --inputs melt_DD.json.filled
java -jar ../../software/cromwell-42.jar run melt.wdl --inputs melt_DD.json.filled
cd - 
}

run_baf() {
cd wdls
java -jar ../../software/wdltool-0.14.jar validate baf.wdl
java -jar ../../software/wdltool-0.14.jar inputs baf.wdl > baf_DD.json
python ../scripts/render_json_inputs.py -json baf_DD.json -tab /cluster/home/qinqian/yangfan/phaseC_SV/input/bunny_BAM_DD_final.txt -contig /cluster/home/qinqian/yangfan/phaseC_SV/input/hg38_contig_list.txt -baf

java -Dconfig.file=../cluster/pbs_q1.conf -jar ../../software/cromwell-42.jar run baf.wdl --inputs baf_DD.json.filled
cd - 
}

run_pesr() {
cd wdls
java -jar ../../software/wdltool-0.14.jar validate PESR.wdl
java -jar ../../software/wdltool-0.14.jar inputs PESR.wdl > PESR_DD.json
python ../scripts/render_json_inputs.py -json PESR_DD.json -tab /cluster/home/qinqian/yangfan/phaseC_SV/input/bunny_BAM_DD_final.txt -contig /cluster/home/qinqian/yangfan/phaseC_SV/input/hg38_contig_list.txt -PESR

java -Dconfig.file=../cluster/pbs_q2.conf -jar ../../software/cromwell-42.jar run PESR.wdl --inputs PESR_DD.json.filled
cd - 
}

#get_meta

#run_bincov &
#run_delly &
#run_baf & 
#run_pesr
#run_manta 
#debug melt
#for i in *depth; do awk '{n+=$3}END{print n/NR}' $i>${i}.mean& done
#run_melt  ## cannot run with qsub or wdltools, run with normal mode, see test_melt_success.sh
#wait

ls /cluster/home/qinqian/yangfan/phaseC_SV/dump/manta/DD_negative/*/results/variants/dip*gz > /cluster/home/qinqian/yangfan/phaseC_SV/input/all_DD_manta_vcf.txt

#cd wdls
#java -jar ../../software/wdltool-0.14.jar validate 01_pesr_clustering_single_algorithm_local_manta.wdl
#java -jar ../../software/wdltool-0.14.jar inputs 01_pesr_clustering_single_algorithm_local_manta.wdl > cluster_DD.json
#python ../scripts/render_json_inputs.py -json cluster_DD.json -tab /cluster/home/qinqian/yangfan/phaseC_SV/input/all_DD_manta_vcf.txt -contig /cluster/home/qinqian/yangfan/phaseC_SV/input/hg38_contig_list.txt -cluster
#java -Dconfig.file=../cluster/pbs_q1.conf -jar ../../software/cromwell-42.jar run 01_pesr_clustering_single_algorithm_local_manta.wdl --inputs cluster_DD.json.filled

/cluster/home/qinqian/yangfan/phaseC_SV/src/wdls/cromwell-executions/cluster_pesr_algorithm/39713bdb-56ad-4986-abdc-c7c54cb5ea3c/call-concat_vcfs/execution/s394g01018.manta.vcf.gz

rm raw.makeMatrix_input.txt
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
    #scripts/cnMOPS_workflow.sh -o ../dump/cnmops/s394g01018_2/ -p s394g01018 raw.makeMatrix_input.txt -c

