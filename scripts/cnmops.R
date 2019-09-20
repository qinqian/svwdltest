set.seed(0)
library(cn.mops)

library(Biobase)
library(GenomicRanges)
library(GenomeInfoDb)
cn.mopsVersion <- packageDescription("cn.mops")$Version

chrs <- c()
BAMFile <- c("/cluster/home/bunny/WGS/output/result/P18016745LD01-17F05750/BAM/P18016745LD01-17F05750.aligned.duplicate_marked.sorted.bam", '/cluster/home/bunny/WGS/output/result/R18054603LD01-17Y082/BAM/R18054603LD01-17Y082.aligned.duplicate_marked.sorted.bam')
bamDataRange <- getReadCountsFromBAM(BAMFile, refSeqNames='chr22', sampleNames=c("P18016745LD01-17F05750", 'R18054603LD01-17Y082'), WL=1000, parallel=10)
res <- cn.mops(bamDataRange)

resCNMOPSX <- calcIntegerCopyNumbers(res)

pdf("002.pdf")
segplot(res,sampleIdx=1,seqnames="chr22")
dev.off()

segm <- as.data.frame(segmentation(resCNMOPSX))
CNVs <- as.data.frame(cnvs(resCNMOPSX))
CNVRegions <- as.data.frame(cnvr(resCNMOPSX))

write.csv(segm,file="segmentation.csv", quote=F)
write.csv(CNVs,file="cnvs.csv", quote=F)
write.csv(CNVRegions,file="cnvr.csv", quote=F)

