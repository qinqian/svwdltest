#!/usr/bin/env bash

#############################
#    gnomAD SV Discovery    #
#############################

# Copyright (c) 2017 Ryan L. Collins
# Distributed under terms of the MIT License (see LICENSE)
# Contact: Ryan L. Collins <rlcollins@g.harvard.edu>
# gnomAD credits: http://gnomad.broadinstitute.org/

# Wrapper to run MELT (Gardner et al., Unpublished)

# Dependencies (not loaded in this script):
#   Java ≥1.7
#   Bowtie2

#####Usage statement
usage(){
cat <<EOF
usage: runMELT.sh [-h] [-L read length] [-I insert size] bam ref cov MELT_DIR RUN_DIR

Runs MELT for mobile element detection. Requires paired-end deep (>10X) WGS data mapped with BWA.

Positional arguments:
  bam        Full path to mapped bam file
  ref        Full path to reference FASTA
  cov        Approximate nucleotide coverage of bam file (+/- 2x is ok)
  MELT_DIR   Full path to MELT install directory
  RUN_DIR    Full path to directory for MELT output

Optional arguments:
  -h  HELP          Show this help message and exit
  -L  read length   Average read length of library
  -I  insert size   Average insert size of library
EOF
}

#####Read options
readlength="UNSET"
insertsize="UNSET"
#Parse arguments
while getopts ":L:I:h" opt; do
  case "$opt" in
    h)
      usage
      exit 0
      ;;
    L)
      readlength=${OPTARG}
      ;;
    I)
      insertsize=${OPTARG}
      ;;
  esac
done
shift $((${OPTIND} - 1))

#####Read arguments
bam=$1           #sorted, indexed, PE bam
ref=$2           #reference.fa
cov=$3           #approximate nucleotide coverage of the library
MELT_DIR=$4      #full path to MELT directory
RUN_DIR=$5       #run directory for this sample

#####Check for required input
if [ -z ${bam} ] || [ -z ${ref} ] || [ -z ${cov} ] || [ -z ${MELT_DIR} ] || [ -z ${RUN_DIR} ]; then
  usage
  exit 0
fi

#####Check mean readlength of library (if not optioned)
if [ ${readlength} == "UNSET" ]; then
  # (Samples top 100,000 proper, non-dup, primary pairs)
  readlength=$( samtools view -f 3 -F 3852 ${bam} | head -n100000 | \
                awk '{ sum+=length($10) }END{ print sum/NR }' | cut -f1 -d\. )
fi

#####Check mean insert size of library
if [ ${insertsize} == "UNSET" ]; then
  # (Samples top 100,000 proper, non-dup, primary pairs)
  insertsize=$( samtools view -f 3 -F 3852 ${bam} | head -n100000 | \
                awk '{ sum+=sqrt(($9)^2) }END{ print sum/NR }' | cut -f1 -d\. )
fi

#####Floor coverage value, read length, and insert size
cov=$( echo ${cov} | cut -f1 -d\. )
readlength=$( echo ${readlength} | cut -f1 -d\. )
insertsize=$( echo ${insertsize} | cut -f1 -d\. )

#####Create transposons reference list
ls ${MELT_DIR}/me_refs/Hg38/*zip | sed 's/\*//g' > \
${RUN_DIR}/transposon_reference.list

#####Create output directory if it doesn't exist
if ! [ -e ${RUN_DIR} ]; then
  mkdir ${RUN_DIR}
fi

#####Run MELT Single
cd ${RUN_DIR}
java -Xmx12G -jar ${MELT_DIR}/MELT.jar Single \
  -bamfile ${bam} \
  -h ${ref} \
  -c ${cov} \
  -r ${readlength} \
  -e ${insertsize} \
  -d 40000000 \
  -t ${RUN_DIR}/transposon_reference.list \
  -n ${MELT_DIR}/add_bed_files/Hg38/Hg38.genes.bed \
  -w ${RUN_DIR}

