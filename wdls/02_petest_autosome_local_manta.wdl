# Run petest on a single autosome, parallelizing across a fixed split size
workflow petest_autosome {
  File vcf                      # Input VCF
  String discfile               # Discordant pair file
  File medianfile               # Median file
  File discfile_idx             # Tabix index of discordant pair file
  String batch                  # Batch ID
  String chrom                  # Chromosome being processed
  Int split_size                # Number of lines in each petest split

  # Compute the length of the suffix needed to accomodate all splits
  call compute_suffix_len {
    input:
      vcf=vcf,
      chrom=chrom,
      split_size=split_size
  }

  # Split the VCF into smaller chunks
  call split_vcf {
    input:
      vcf=vcf,
      batch=batch,
      chrom=chrom,
      split_size=split_size,
      suffix_len=compute_suffix_len.len
  }

  # Run petest on each split
  scatter (split in split_vcf.split_vcfs) {
    # Add VCF header to split
    call reheader_split {
      input:
        vcf=vcf,
        split=split
    }

    # Run petest
    call petest {
      input:
        vcf=reheader_split.split_w_header,
        prefix=basename(split),
        discfile=discfile,
        medianfile=medianfile,
        discfile_idx=discfile_idx,
    }
  }

  # Merge splits into single file
  call merge_splits {
    input:
      stats=petest.stats,
      prefix="${batch}.manta.${chrom}"
  }

  output {
    File stats = merge_splits.merged_stats
  }
}

# Compute the length of the suffix necessary to accommodate all splits
task compute_suffix_len {
  File vcf
  String chrom
  Int split_size

  command <<<
    tabix -p vcf ${vcf};
    python3 <<CODE
    import numpy as np
    import pysam
    vcf = pysam.VariantFile('${vcf}')
    for i, record in enumerate(vcf.fetch('${chrom}')):
      continue
    n_records = i + 1
    n_splits = int(np.ceil(n_records / ${split_size}))
    suffix_len = max(int(np.ceil(np.log10(n_splits))), 1)
    print(suffix_len)
    CODE
  >>>

  output {
    Int len = read_int(stdout())
  }
}

# Split VCF into fixed size chunks
task split_vcf {
  File vcf
  String batch
  String chrom
  
  Int split_size
  Int suffix_len

  command {
    tabix -p vcf ${vcf};
    tabix ${vcf} ${chrom} | sort -R | split -a ${suffix_len} -d -l ${split_size} - ${batch}.manta.split.
  }

  output {
    Array[File] split_vcfs = glob("${batch}.manta.split.*")
  }
}

# Restore VCF header to split files
task reheader_split {
  File vcf
  File split

  command {
    cat <(zcat ${vcf} | sed -n -e '/^#/p') ${split} | bgzip -c > ${basename(split)}.vcf.gz
  }

  output {
    File split_w_header = "${basename(split)}.vcf.gz"
  }
}

# Run petest
task petest {
  File vcf
  String discfile
  File medianfile
  File discfile_idx
  String prefix
 
  command { 
    svtk pe-test -o 1000 --index ${discfile_idx} --medianfile ${medianfile} ${vcf} ${discfile} ${prefix}.stats
  }
  
  output {
    File stats = "${prefix}.stats"
  }
}

# Merge split petest results into single file
task merge_splits {
  Array[File] stats
  String prefix

  command <<<
    while read split; do
      sed -e '1d' $split;
    done < ${write_tsv(stats)} | cat <(head -n1 ${stats[0]}) - > ${prefix}.stats
  >>>

  output {
    File merged_stats = "${prefix}.stats"
  }
}

