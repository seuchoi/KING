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
