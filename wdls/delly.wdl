workflow delly {
   File inputSamplesFile
   Array[Array[File]] Bams = read_tsv(inputSamplesFile)
   File refFasta
   File refFastafai
   String outputDir

   scatter (bam in Bams) {
       call delly_hg38 {input: 
           bamFile=bam[1],
           bamIndex=bam[2],
           refFasta=refFasta, 
           reffai=refFastafai,
           outputDir=outputDir,
           outputPrefix=bam[0]
       }
   }

   output {
       Array[File] bcfs = delly_hg38.bcf
       Array[File] indexes = delly_hg38.bcfcsi
   }
}

task delly_hg38 {
   File refFasta
   String outputDir
   File bamFile
   File bamIndex
   File reffai
   String outputPrefix

   command <<<
       source activate /cluster/home/qinqian/.conda/envs/vcf
       mkdir -p ${outputDir}/${outputPrefix} 
       delly call -g ${refFasta} -o ${outputDir}/${outputPrefix}/${outputPrefix}.delly.bcf ${bamFile}
   >>>

   output {
     File bcf = "${outputDir}/${outputPrefix}/${outputPrefix}.delly.bcf"
     File bcfcsi = "${outputDir}/${outputPrefix}/${outputPrefix}.delly.bcf.csi"
   }
}

