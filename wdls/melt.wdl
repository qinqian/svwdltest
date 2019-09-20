workflow melt {
   File inputSamplesFile
   Array[Array[File]] Bams = read_tsv(inputSamplesFile)
   File MELT
   File refFasta
   File refFastafai
   String outputDir
   scatter (bam in Bams) {
       call melt_hg38 {
           input: 
           bamFile=bam[1],
           bamIndex=bam[2],
           samplePrefix=bam[0],
           refFasta=refFasta, 
           reffai=refFastafai,
           MELT=MELT,
           outputDir=outputDir,
       }
   }
}

task melt_hg38 {
   File MELT
   File refFasta
   String outputDir
   File bamFile
   File bamIndex
   File reffai
   String samplePrefix

   command <<<
   source activate /cluster/home/qinqian/.conda/envs/vcf
   mkdir -p ${outputDir}/${samplePrefix}

   ln -s ${bamIndex} ${bamFile}.bai

   depth=$(cat ${outputDir}/${samplePrefix}.depth.mean)
   /bin/bash /cluster/home/qinqian/yangfan/phaseC_SV/src/scripts/runMELT_2.0.5_patch_hg38.sh ${bamFile} ${refFasta} $depth ${MELT} ${outputDir}/${samplePrefix}
   >>>

   output {
     File ALU = "${outputDir}/${samplePrefix}/ALU.final_comp.vcf"
     File LINE = "${outputDir}/${samplePrefix}/LINE1.final_comp.vcf"
     File SVA = "${outputDir}/${samplePrefix}/SVA.final_comp.vcf"
   }
}

