
workflow vcf2baf {
   File inputSamplesFile
   Array[Array[File]] Bams = read_tsv(inputSamplesFile)
   String outputDir
   scatter (bam in Bams) {
       call gatk2baf {input: 
           outputDir=outputDir,
           outputPrefix=bam[0],
           vcf=bam[6]
       }
   }

   output {
       Array[File] bafs = gatk2baf.baf
   }
}

task gatk2baf {
   File vcf
   String outputDir
   String outputPrefix

   command <<<
       source activate /cluster/home/qinqian/.conda/envs/vcf

       mkdir -p ${outputDir}/${outputPrefix} 

       /cluster/home/qinqian/yangfan/phaseC_SV/software/gnomad-sv-pipeline/gnomad_sv_pipeline_scripts/module_00/vcf2baf.sh -z ${vcf} ${outputDir}/${outputPrefix}/${outputPrefix}.baf
   >>>

   output {
     File baf = "${outputDir}/${outputPrefix}/${outputPrefix}.baf.gz"
     File bafindex = "${outputDir}/${outputPrefix}/${outputPrefix}.baf.gz.tbi"
   }
}

