workflow manta {
   File inputSamplesFile
   Array[Array[File]] Bams = read_tsv(inputSamplesFile)
   File refFasta
   File refFastafai
   String outputDir
   scatter (bam in Bams) {
       call manta_hg38 {input: 
           bamFile=bam[1],
           bamIndex=bam[2],
           refFasta=refFasta, 
           reffai=refFastafai,
           outputDir=outputDir,
           outputPrefix=bam[0]
       }
   }

   output {
       Array[File] vcfgz = manta_hg38.vcfgz
   }
}

task manta_hg38 {
   File refFasta
   File reffai
   String outputDir
   String outputPrefix
   File bamFile
   File bamIndex

   command <<<
       mkdir -p ${outputDir}/${outputPrefix} 
       python2 /cluster/home/qinqian/yangfan/phaseC_SV/software/manta-1.0.3.centos5_x86_64/bin/configManta.py\
       	 --bam ${bamFile} \
       	 --referenceFasta ${refFasta} \
       	 --runDir ${outputDir}/${outputPrefix}
       python2 ${outputDir}/${outputPrefix}/runWorkflow.py -j 20 -m local
   >>>

   output {
     File vcfgz = "${outputDir}/${outputPrefix}/results/variants/candidateSV.vcf.gz"
   }
}

