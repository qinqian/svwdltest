import 'bincov_by_chrom.wdl' as bin_chrom

workflow bincov {
   File inputSamplesFile
   Array[Array[File]] Bams = read_tsv(inputSamplesFile)
   File contigList
   File mask
   String outDir

   scatter (bam in Bams) {
      call bin_chrom.bincov_chrom as compute {input: 
          bamFile=bam[1],
          bamIndex=bam[2],
          outPrefix=bam[0],
          outDir=outDir,
          contigList=contigList,
          mask=mask
      }
   }

   output {
      Array[Array[File]] raw = compute.raw
      Array[Array[File]] norm = compute.norm
   }
}

