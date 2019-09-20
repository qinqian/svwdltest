workflow collectPESR {
   File inputSamplesFile
   Array[Array[File]] Bams = read_tsv(inputSamplesFile)
   String outputDir

   scatter (bam in Bams) {
       call PESR {input: 
           bamFile=bam[1],
           bamIndex=bam[2],
           outputDir=outputDir,
           outputPrefix=bam[0]
       }
   }

   output {
       Array[File] split = PESR.splitbed
       Array[File] disc = PESR.discbed
   }
}

task PESR {
   String outputDir
   String outputPrefix
   File bamFile
   File bamIndex

   command <<<
       source activate /cluster/home/qinqian/.conda/envs/vcf
       ln -s ${bamIndex} ${bamFile}.bai
       mkdir -p ${outputDir}/${outputPrefix}
       svtk collect-pesr -z ${bamFile} ${outputDir}/${outputPrefix} ${outputDir}/${outputPrefix}/${outputPrefix}_split.bed.gz ${outputDir}/${outputPrefix}/${outputPrefix}_discordant.bed.gz
   >>>

   output {
     File splitbed = "${outputDir}/${outputPrefix}/${outputPrefix}_split.bed.gz"
     File discbed = "${outputDir}/${outputPrefix}/${outputPrefix}_discordant.bed.gz"
   }
}
