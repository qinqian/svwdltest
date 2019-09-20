import "02_petest.wdl" as petest
#import "02_srtest.wdl" as srtest
#import "02_rdtest.wdl" as rdtest
#import "02_baftest.wdl" as baftest

# Assess PE, SR, RD, and BAF evidence for every variant in a VCF
workflow assess_evidence {
  File vcf                      # Input VCF
  File discfile                 # Discordant pair file
  File discfile_idx             # Tabix index of discordant pair file
  File splitfile                # Split read file
  File splitfile_idx            # Tabix index of split read file
  File coveragefile             # Bincov matrix
  File coveragefile_idx         # Tabix index of bincov matrix
  File medianfile               # Median coverage of each sample
  File baf_metrics              # Matrix of BAF statistics
  File baf_metrics_idx          # Tabix index of BAF matrix
  File famfile                  # Batch fam file 
  File autosome_contigs         # Autosomes .fai
  File allosome_contigs         # Allosomes .fai
  File rmsk                     # Repeatmasker track
  File segdups                  # Seg dups track
  String batch                  # Batch ID
  Int PE_split_size             # Number of lines in each petest split
  Int SR_split_size             # Number of lines in each srtest split
  Int RD_split_size             # Number of lines in each rdtest split
  Int BAF_split_size            # Number of lines in each baftest split
  Array[String] samples

  call petest.petest_by_chrom as pe{
    input:
      vcf=vcf,
      discfile=discfile,
      medianfile=medianfile,
      discfile_idx=discfile_idx,
      famfile=famfile,
      autosome_contigs=autosome_contigs,
      allosome_contigs=allosome_contigs,
      batch=batch,
      split_size=PE_split_size
  }

  #call srtest.srtest_by_chrom as sr {
  #  input:
  #    vcf=vcf,
  #    splitfile=splitfile,
  #    medianfile=medianfile,
  #    splitfile_idx=splitfile_idx,
  #    famfile=famfile,
  #    autosome_contigs=autosome_contigs,
  #    allosome_contigs=allosome_contigs,
  #    batch=batch,
  #    split_size=SR_split_size
  #}

  #call rdtest.rdtest_by_chrom as rd {
  #  input:
  #    vcf=vcf,
  #    coveragefile=coveragefile,
  #    coveragefile_idx=coveragefile_idx,
  #    medianfile=medianfile,
  #    famfile=famfile,
  #    autosome_contigs=autosome_contigs,  
  #    allosome_contigs=allosome_contigs,
  #    batch=batch,
  #    split_size=RD_split_size
  #}

  #call baftest.baftest_by_chrom as baf {
  #  input:
  #    vcf=vcf,
  #    samples=samples,
  #    baf_metrics=baf_metrics,
  #    baf_metrics_idx=baf_metrics_idx,
  #    autosome_contigs=autosome_contigs,
  #    batch=batch,
  #    split_size=BAF_split_size
  #}
  #
  #call aggregate_pesr as agg {
  #  input:
  #    vcf=vcf,
  #    petest=pe.petest,
  #    srtest=sr.srtest,
  #    rdtest=rd.rdtest,
  #    baftest=baf.baftest,
  #    segdups=segdups,
  #    rmsk=rmsk
  #}
  
  output {
    #File metrics = select_first([agg.metrics, pe.metrics, baf.metrics, rd.metrics, sr.metrics])
    File metrics = select_first([pe.metrics])
  }
}

task aggregate_pesr {
  File vcf
  File petest
  File srtest
  File rdtest
  File baftest
  File segdups
  File rmsk

  command <<<
    scripts/aggregate.py -v ${vcf} \
      -p ${petest} -s ${srtest} -r ${rdtest} -b ${baftest} \
      --segdups ${segdups} --rmsk ${rmsk} \
      pesr.metrics
  >>>

  output {
    File metrics = "pesr.metrics"
  }
}

