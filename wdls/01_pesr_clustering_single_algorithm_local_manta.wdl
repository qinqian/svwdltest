import "00_pesr_processing_single_algorithm.wdl" as standardize

workflow cluster_pesr_algorithm {
  Array[File] vcfs
  File contigs
  String batch
  String algorithm
  Int dist
  Float frac
  Int svsize
  String svtypes
  String flags

  Array[Array[String]] contiglist = read_tsv(contigs)

  scatter (vcf in vcfs) {
      call standardize.preprocess_algorithm as std {input: 
         vcf=vcf, 
         contigs=contigs,
         sample=basename(vcf),
         algorithm='manta',
         min_svsize=50,
      }
  }

  scatter (contig in contiglist) {
    call vcfcluster {
      input:
        vcfs=std.std_vcf,
        batch=batch,
        algorithm=algorithm,
        chrom=contig[0],
        dist=dist,
        frac=frac,
        svsize=svsize,
        flags=flags,
        svtypes=svtypes
    }
  }

  call concat_vcfs {
    input:
      vcfs=vcfcluster.clustered_vcf,
      batch=batch,
      algorithm=algorithm
  }


  output {
    File clustered_vcf = concat_vcfs.vcf
  }
}

task vcfcluster {
  Array[File] vcfs
  String batch
  String algorithm
  String chrom

  # VCFcluster parameters
  Int dist
  Float frac
  Int svsize
  String svtypes
  String flags

  command <<<
    source activate /cluster/home/qinqian/.conda/envs/vcf
    for f in ${sep=' ' vcfs}; do tabix -p vcf -f $f; done;

    svtk vcfcluster ${write_tsv(vcfs)} stdout \
        -r ${chrom} \
        -p ${batch}_${algorithm}_${chrom} \
        -d ${dist} \
        -f ${frac} \
        -z ${svsize} \
        -t ${svtypes} \
        ${flags} \
      | vcf-sort -c \
      | bgzip -c > ${batch}.${algorithm}.${chrom}.vcf.gz
  >>>

  output {
    File clustered_vcf="${batch}.${algorithm}.${chrom}.vcf.gz"
  }
}

task concat_vcfs {
  Array[File] vcfs
  String batch
  String algorithm

  command {
    source activate /cluster/home/qinqian/.conda/envs/vcf
    vcf-concat ${sep=' ' vcfs} | vcf-sort -c | bgzip -c > ${batch}.${algorithm}.vcf.gz;
    tabix -p vcf ${batch}.${algorithm}.vcf.gz;
  }

  output {
    File vcf="${batch}.${algorithm}.vcf.gz"
    File idx="${batch}.${algorithm}.vcf.gz.tbi"
  }
}
