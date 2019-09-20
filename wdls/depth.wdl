workflow collectDepth {
   String outputDir
   File inputSamplesFile
   Array[Array[File]] Bams = read_tsv(inputSamplesFile)

   scatter (bam in Bams) {
       call depth {
           input: 
           bamFile=bam[1],
           bamIndex=bam[2],
           samplePrefix=bam[0],
           outputDir=outputDir,
       }
   }
}

task depth {
   File bamFile
   File bamIndex
   String outputDir
   String samplePrefix

   command <<<
   ln -s ${bamIndex} ${bamFile}.bai
   mkdir -p ${outputDir}/${samplePrefix}

   samtools depth ${bamFile} > ${outputDir}/${samplePrefix}.depth
   depth=$(awk '{n+=$3} END {print n/NR}' ${outputDir}/${samplePrefix}.depth)
   echo $depth > ${outputDir}/${samplePrefix}.depth.mean
   >>>

   output {
     File depth = "${outputDir}/${samplePrefix}.depth"
     File meandepth = "${outputDir}/${samplePrefix}.depth.mean"
   }
}

