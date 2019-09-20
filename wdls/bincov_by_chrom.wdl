workflow bincov_chrom {
   File contigList
   File mask
   File bamFile
   File bamIndex
   String outPrefix
   String outDir

   Array[Array[String]] contigs = read_tsv(contigList)
   scatter (contig in contigs) {
     call compute_bincov_by_chrom {input:
         bamFile=bamFile,
         bamIndex=bamIndex,
         mask=mask,
         contig=contig[0],
         outPrefix=outPrefix,
         outDir=outDir
     }
   }

   output {
     Array[File] raw = compute_bincov_by_chrom.outputBed
     Array[File] norm = compute_bincov_by_chrom.outputNormBed
   }
}

task compute_bincov_by_chrom {
   File bamFile
   File bamIndex
   String contig
   File mask
   String outDir
   String outPrefix

   command <<<
   source activate /cluster/home/qinqian/.conda/envs/vcf

   mkdir -p ${outDir}/${outPrefix}
   ln -s ${bamIndex} ${bamFile}.bai
   /cluster/home/qinqian/yangfan/phaseC_SV/software/WGD/bin/binCov.py ${bamFile} ${contig} ${outDir}/${outPrefix}/${contig}.rawcov.bed \
    -n ${outDir}/${outPrefix}/${contig}.normcov.bed \
    -b 100 \
    -m nucleotide \
    -x ${mask} \
    -z 
   >>>

   output {
     File outputBed = "${outDir}/${outPrefix}/${contig}.rawcov.bed.gz"
     File outputNormBed = "${outDir}/${outPrefix}/${contig}.normcov.bed.gz"
   }
}

