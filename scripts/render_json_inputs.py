import json
import pandas as pd
import os
import argparse
from collections import defaultdict

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-json', required=True)
    parser.add_argument('-tab', required=True)
    parser.add_argument('-melt', action="store_true")
    parser.add_argument('-bincov', action="store_true")
    parser.add_argument('-delly', action="store_true")
    parser.add_argument('-manta', action="store_true")
    parser.add_argument('-process', action="store_true")
    parser.add_argument('-PESR', action="store_true")
    parser.add_argument('-baf', action="store_true")
    parser.add_argument('-depth', action="store_true")
    parser.add_argument('-cluster', action="store_true")
    parser.add_argument('-contig', default='/cluster/home/qinqian/yangfan/phaseC_SV/input/hg38_contig_list.txt')
    args = parser.parse_args()
    
    if args.bincov:
        with open(args.json) as j:
            wdl_json = json.load(j)
        wdl_json['bincov.contigList'] = args.contig
        wdl_json['bincov.mask'] = '/cluster/home/qinqian/yangfan/phaseC_SV/software/WGD/refs/WGD_scoring_mask.rawCov.100bp.hg38.bed'
        wdl_json['bincov.inputSamplesFile'] = args.tab
        #wdl_json['bincov.outDir'] = '/cluster/home/qinqian/yangfan/phaseC_SV/dump/cnmops/s394g01018_2'
        #wdl_json['bincov.outDir'] = '/cluster/home/qinqian/yangfan/phaseC_SV/dump/cnmops/s394g01018_2_test'
        wdl_json['bincov.outDir'] = '/cluster/home/qinqian/yangfan/phaseC_SV/dump/cnmops/dragon'
        os.system('mkdir -p %s' % wdl_json['bincov.outDir'])

    if args.manta:
        with open(args.json) as j:
            wdl_json = json.load(j)
        wdl_json['manta.inputSamplesFile'] = args.tab
        wdl_json['manta.refFasta'] = '/cluster/apps/refseq/GATK/hg38/Homo_sapiens_assembly38.fasta'
        wdl_json['manta.refFastafai'] = '/cluster/apps/refseq/GATK/hg38/Homo_sapiens_assembly38.fasta.fai'
        wdl_json['manta.outputDir'] = '/cluster/home/qinqian/yangfan/phaseC_SV/dump/manta/DD_negative'
        os.system('mkdir -p %s' % wdl_json['manta.outputDir'])

    if args.delly:
        with open(args.json) as j:
            wdl_json = json.load(j)
        wdl_json['delly.inputSamplesFile'] = args.tab
        wdl_json['delly.refFasta'] = '/cluster/apps/refseq/GATK/hg38/Homo_sapiens_assembly38.fasta'
        wdl_json['delly.refFastafai'] = '/cluster/apps/refseq/GATK/hg38/Homo_sapiens_assembly38.fasta.fai'
        wdl_json['delly.outputDir'] = '/cluster/home/qinqian/yangfan/phaseC_SV/dump/delly/DD_negative'
        os.system('mkdir -p %s' % wdl_json['delly.outputDir'])

    if args.melt:
        with open(args.json) as j:
            wdl_json = json.load(j)
        wdl_json['melt.inputSamplesFile'] = args.tab
        wdl_json['melt.refFasta'] = '/cluster/apps/refseq/GATK/hg38/Homo_sapiens_assembly38.fasta'
        wdl_json['melt.refFastafai'] = '/cluster/apps/refseq/GATK/hg38/Homo_sapiens_assembly38.fasta.fai'
        wdl_json['melt.outputDir'] = '/cluster/home/qinqian/yangfan/phaseC_SV/dump/melt/DD_negative'
        os.system('mkdir -p %s' % wdl_json['melt.outputDir'])
        wdl_json['melt.MELT'] = '/cluster/home/qinqian/yangfan/phaseC_SV/software/MELTv2.0.5_patch/'

    if args.depth:
        with open(args.json) as j:
            wdl_json = json.load(j)
        wdl_json['collectDepth.inputSamplesFile'] = args.tab
        wdl_json['collectDepth.outputDir'] = '/cluster/home/qinqian/yangfan/phaseC_SV/dump/melt/DD_negative/'
        os.system('mkdir -p %s' % wdl_json['collectDepth.outputDir'])

    if args.baf:
        with open(args.json) as j:
            wdl_json = json.load(j)
        wdl_json['vcf2baf.inputSamplesFile'] = args.tab
        #wdl_json['vcf2baf.outputDir'] = '/cluster/home/qinqian/yangfan/phaseC_SV/dump/evidence/DD_negative'
        wdl_json['vcf2baf.outputDir'] = '/cluster/home/qinqian/yangfan/phaseC_SV/dump/evidence/dragon'
        os.system('mkdir -p %s' % wdl_json['vcf2baf.outputDir'])

    if args.PESR:
        with open(args.json) as j:
            wdl_json = json.load(j)
        wdl_json['collectPESR.inputSamplesFile'] = args.tab
        wdl_json['collectPESR.outputDir'] = '/cluster/home/qinqian/yangfan/phaseC_SV/dump/evidence/DD_negative'
        os.system('mkdir -p %s' % wdl_json['collectPESR.outputDir'])

    if args.process:
        wdl_json = {
          "preprocess_pesr.min_svsize": 50,
          "preprocess_pesr.delly_vcf": "/cluster/home/qinqian/yangfan/phaseC_SV/dump/delly/s394g01018_test/R18055980LD01/R18055980LD01.delly.vcf",
          "preprocess_pesr.melt_vcf": "/cluster/home/qinqian/yangfan/phaseC_SV/dump/melt/s394g01018/R18055980LD01/melt.vcf",
          "preprocess_pesr.contigs": "/cluster/apps/refseq/GATK/hg38/Homo_sapiens_assembly38.fasta.fai",
          "preprocess_pesr.sample": "R18055980LD01",
          "preprocess_pesr.manta_vcf": "/cluster/home/data_share/seq-data/raw-data/DRAGEN_SV/R18055981LD01/results/variants/candidateSV.vcf.gz" ## must be uncompressed
        }

    if args.cluster:
        wdl_json = {
          "cluster_pesr_algorithm.svtypes": "BND",
          #"cluster_pesr_algorithm.flags": "--call-null-sites --include-reference-sites",
          "cluster_pesr_algorithm.flags": " ",
          "cluster_pesr_algorithm.svsize": "30",
          "cluster_pesr_algorithm.frac": "0.1",
          #"cluster_pesr_algorithm.blacklist": "/cluster/home/qinqian/yangfan/phaseC_SV/software/WGD/refs/WGD_scoring_mask.rawCov.100bp.hg38.bed",
          "cluster_pesr_algorithm.dist": "500",
          "cluster_pesr_algorithm.algorithm": "manta",
          "cluster_pesr_algorithm.contigs": args.contig,
          "cluster_pesr_algorithm.vcfs": [s.strip() for s in open(args.tab).readlines()],
          "cluster_pesr_algorithm.batch": "s394g01018"
        }
    with open(args.json+'.filled', 'w') as out:
        json.dump(wdl_json, out)
