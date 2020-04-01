start_time <- Sys.time()

##### call arguments
args <- commandArgs(trailingOnly=T)
fileheader <- args[1]
relfile<-paste0(fileheader,".kin0.related")
famfile<-paste0(fileheader,".fam")
unrelfile<-paste0(fileheader,".kin0.unrelated3d.tsv")

source("removerelated.R")
######
###### read files
related<-fread(relatedfile,header=T,data.table=F,sep="\t")
famid<-fread(famfile,header=F,data.table=F,sep="\t")
relsampes<-related[,c("ID1","ID2")]
allsam<-famid$V1
newidskept<-removerelated(relsampes,allsam,random=FALSE)
write.table(newidskept,unrelfile,col.names=F,row.names=F,quote=F,sep="\t")

###### complete time conversion
end_time <- Sys.time()
difftime<-end_time - start_time
print(paste("Comuptational time of",round(difftime[[1]],digits=2)))

###### quit R
sessionInfo()
quit("no")





##### call library
library(SeqArray)

##### call arguments
args <- commandArgs(trailingOnly=T)
vcf <- args[1]
gds_out <- paste(args[2],".gds",sep="")
ncpu <- as.numeric(args[3])

##### convert vcf to gds
seqVCF2GDS(vcf, gds_out, storage.option="LZMA_RA", parallel=ncpu, verbose=TRUE)

##### complete conversion
end_time <- Sys.time()
difftime<-end_time - start_time
print(paste("Comuptational time of",round(difftime[[1]],digits=2),"secs"))

###### quit R
sessionInfo()
quit("no")
