## charles ferté,MD
## Sage Bionetworks 
## "2012-dec-06"

## KRAS project LUAD
## input the RNASeq data

require(synapseClient)
require(Biobase)
## synapse Login
synapseLogin("charles.ferte@sagebase.org","charles")

### magic option
options(stringsAsFactors=FALSE)

#######################################################################################################
# 1. load the data files  of TCGA LUAD 
#######################################################################################################
load("/home/cferte/FELLOW/cferte/KRAS_Analysis/mutations_LUAD.RData")
load("/home/cferte/FELLOW/cferte/KRAS_Analysis/KRAS_LUAD.RData")
table(KRAS_LUAD)

# ###################################################################################################
# 2. plot the overall mutation rate in LUAD (y axis = mutations per megabase, x axis= samples )
# ###################################################################################################
# 
# MUTRATE <- apply(MATMUT_LUAD,2,sum)
# par(mfrow=c(1,1))
# x <- sort(MUTRATE,decreasing=TRUE)*95859/1000000
# summary(x)
# #plot(x,pch=20,cex=.01,xlab="249 LUAD TCGA samples",
# #ylab="Overall number of mutations per Mb")
# #abline(h=quantile(x=x,probs=.15),lty=2,col="red")
# #abline(h=quantile(x=x,probs=.75),lty=2,col="red")
# 
# plot(log10(sort(MUTRATE,decreasing=TRUE)*94771/1000000),pch=20,cex=.5,xlab="249 LUAD TCGA samples",
#      ylab="Overall number of mutations per Mb (log10 scale)",yaxt="n")
# axis(side=2,at=c(.5,1,1.5,2,2.5,3),labels=c(3,10,30,100,300,1000))
# abline(h=log10(quantile(x=x,probs=.75)),lty=2,col="red")
# abline(h=log10(quantile(x=x,probs=.25)),lty=2,col="red")
# rm(x)


# ###############################################################################################################################
# # 3. compute the mutations that are associated (overlapping or exclusive) with KRAS mutations
# ###############################################################################################################################
# kras <- apply(MATMUT_LUAD[which("KRAS"==rownames(MATMUT_LUAD)),],2,sum)
# kras <- ifelse(kras==0,0,1)
# kras.overlap <- apply(MATMUT_LUAD,1,function(x){ fisher.test(as.numeric(kras),as.numeric(x),alternative="greater")$p.value})
# kras.exclusive <- apply(MATMUT_LUAD,1,function(x){ fisher.test(as.numeric(kras),as.numeric(x),alternative="less")$p.value})
# 
# table(kras.overlap)
# 
# hist(kras.overlap, breaks=30)
# hist(kras.exclusive, breaks=30)
# 
# table(kras.overlap<.01)
# which(kras.overlap<.05)
# table(kras.exclusive<.01)
# which(kras.exclusive<.05)

################################################################################################################################
# 4. create a new matrix per gene instead of per specific mutation
###############################################################################################################################

# gene <- unique(sapply(strsplit(x=rownames(MATMUT_LUAD),split="_"), function(x){x[[1]]}))
# j <- c()
# new.matmut <- matrix(0,nrow=length(gene),ncol=length(colnames(MATMUT_LUAD)))
# rownames(new.matmut) <- gene
# colnames(new.matmut) <- colnames(MATMUT_LUAD)
# 
# for(i in rownames(new.matmut)){
# new.matmut[i,c(names(which(apply(MATMUT_LUAD[grep(pattern=i,x=rownames(MATMUT_LUAD)),],2,sum)!=0)))] <- 1
# }
# 
# MATMUT_GENE_LUAD <- new.matmut
# save(file="/home/cferte/FELLOW/cferte/KRAS_Analysis/MATMUT_GENE_LUAD.RData",MATMUT_GENE_LUAD)


# ###############################################################################################################################
# # 5. compute the overlap between KRAS specific mutations and specific mutations
# ###############################################################################################################################
# j <- which(KRAS_LUAD %in% c("WT","G12C"))
# G12C<- ifelse(KRAS_LUAD[j]=="G12C",1,0)
# k <- which(apply(MATMUT_LUAD[,j],1,sum)>0)
# G12C.overlap <- apply(MATMUT_LUAD[k,j],1,function(x){fisher.test(as.numeric(G12C),as.numeric(x),alternative="greater")$p.value})
# G12C.exclusive <- apply(MATMUT_LUAD[k,j],1,function(x){ fisher.test(as.numeric(G12C),as.numeric(x),alternative="less")$p.value})
# 
# 
# j <- which(KRAS_LUAD %in% c("WT","G12V"))
# G12V <- ifelse(KRAS_LUAD[j]=="G12V",1,0)
# k <- which(apply(MATMUT_LUAD[,j],1,sum)>0)
# G12V.overlap <- apply(MATMUT_LUAD[k,j],1,function(x){ fisher.test(as.numeric(G12V),as.numeric(x),alternative="greater")$p.value})
# G12V.exclusive <- apply(MATMUT_LUAD[k,j],1,function(x){ fisher.test(as.numeric(G12V),as.numeric(x),alternative="less")$p.value})
# 
# 
# # display the results
# 
# hist(G12C.overlap, breaks=30)
# hist(G12C.exclusive, breaks=30)
# table(G12C.overlap<.05)
# table(G12C.exclusive<.05)
# paste(names(which(G12C.overlap<.05)),collapse=" ")
# paste(names(which(G12C.exclusive<.05)),collapse=" ")
# table(G12V.overlap<.05)
# table(G12V.exclusive<.05)
# hist(G12V.overlap, breaks=30)
# hist(G12V.exclusive, breaks=30)
# paste(names(which(G12V.overlap<.05)),collapse=" ")
# paste(names(which(G12V.exclusive<.05)),collapse=" ")
# 
# # create G12Coverlap.rnk object to be analyzed in the GSEA java (pre ranked test)
# tmp <- G12C.overlap
# tmp <- tmp[-c(grep(pattern="KRAS",x=names(tmp)))]
# rnames <- sapply(strsplit(names(tmp),split="_"),function(x){x[[1]]})
# j <- c()
# vec <- as.numeric(rep(1,times=length(unique(rnames))))
# names(vec) <- unique(rnames)
# for(i in names(vec))
# { 
#   j <- which(rnames==i)
#   vec[i] <- min(tmp[j])
# }
# table(vec)
# plot(sort(vec))
# plot(sort(-log10(vec)))
# foo <- as.data.frame(cbind(names(vec),as.numeric(-log10(as.numeric(vec)))))
# write.table(foo,file="G12Coverlap.rnk",row.names=FALSE,col.names=FALSE,quote=FALSE,sep="\t")
# 
# 
# 
# # create G12Voverlap.rnk object to be analyzed in the GSEA java (pre ranked test)
# tmp <- G12V.overlap
# tmp <- tmp[-c(grep(pattern="KRAS",x=names(tmp)))]
# rnames <- sapply(strsplit(names(tmp),split="_"),function(x){x[[1]]})
# j <- c()
# vec <- as.numeric(rep(1,times=length(unique(rnames))))
# names(vec) <- unique(rnames)
# for(i in names(vec))
# { 
#   j <- which(rnames==i)
#   vec[i] <- min(tmp[j])
# }
# table(vec)
# plot(sort(vec))
# plot(sort(-log10(vec)))
# foo <- as.data.frame(cbind(names(vec),as.numeric(-log10(as.numeric(vec)))))
# write.table(foo,file="G12Voverlap.rnk",row.names=FALSE,col.names=FALSE,quote=FALSE,sep="\t")
# 
# 
# ###############################################################################################################################
# # 7. compute the overlap between KRAS G12C and G12V mutations
# ###############################################################################################################################
# j <- which(KRAS_LUAD %in% c("G12V","G12C"))
# G12C<- ifelse(KRAS_LUAD[j]=="G12C",1,0)
# k <- which(apply(MATMUT_LUAD[,j],1,sum)>0)
# G12C.G12V.overlap <- apply(MATMUT_LUAD[k,j],1,function(x){fisher.test(as.numeric(G12C),as.numeric(x),alternative="greater")$p.value})
# G12C.G12V.exclusive <- apply(MATMUT_LUAD[k,j],1,function(x){ fisher.test(as.numeric(G12C),as.numeric(x),alternative="less")$p.value})
# 
# # create G12C.G12V.overlap.rnk object to be analyzed in the GSEA java (pre ranked test)
# tmp <- G12C.G12V.overlap
# tmp <- tmp[-c(grep(pattern="KRAS",x=names(tmp)))]
# rnames <- sapply(strsplit(names(tmp),split="_"),function(x){x[[1]]})
# j <- c()
# vec <- as.numeric(rep(1,times=length(unique(rnames))))
# names(vec) <- unique(rnames)
# for(i in names(vec))
# { 
#   j <- which(rnames==i)
#   vec[i] <- min(tmp[j])
# }
# table(vec)
# plot(sort(vec))
# plot(sort(-log10(vec)))
# foo <- as.data.frame(cbind(names(vec),as.numeric(-log10(as.numeric(vec)))))
# write.table(foo,file="G12C.G12V.genes.overlap.rnk",row.names=FALSE,col.names=FALSE,quote=FALSE,sep="\t")
# 
# # create G12C.G12V.exclusive.rnk object to be analyzed in the GSEA java (pre ranked test)
# tmp <- G12C.G12V.exclusive
# tmp <- tmp[-c(grep(pattern="KRAS",x=names(tmp)))]
# rnames <- sapply(strsplit(names(tmp),split="_"),function(x){x[[1]]})
# j <- c()
# vec <- as.numeric(rep(1,times=length(unique(rnames))))
# names(vec) <- unique(rnames)
# for(i in names(vec))
# { 
#   j <- which(rnames==i)
#   vec[i] <- min(tmp[j])
# }
# table(vec)
# plot(sort(vec))
# plot(sort(-log10(vec)))
# foo <- as.data.frame(cbind(names(vec),as.numeric(-log10(as.numeric(vec)))))
# write.table(foo,file="G12C.G12V.genes.exclusive.rnk",row.names=FALSE,col.names=FALSE,quote=FALSE,sep="\t")


###############################################################################################################################
# 8. compute the overlap between KRAS G12C and G12V mutations AND genes
###############################################################################################################################

new.matmut <- MATMUT_LUAD

j <- which(KRAS_LUAD %in% c("WT","G12C"))
G12C<- ifelse(KRAS_LUAD[j]=="G12C",1,0)
k <- names(which(apply(new.matmut[,j],1,sum)>1 & apply(new.matmut[,j],1,sum)<length(j)))
G12C.overlap.genes <- apply(new.matmut[k,j],1,function(x){fisher.test(as.numeric(G12C),as.numeric(x),alternative="greater")$p.value})
G12C.exclusive.genes <- apply(new.matmut[k,j],1,function(x){ fisher.test(as.numeric(G12C),as.numeric(x),alternative="less")$p.value})


j <- which(KRAS_LUAD %in% c("WT","G12V"))
G12V <- ifelse(KRAS_LUAD[j]=="G12V",1,0)
k <- names(which(apply(new.matmut[,j],1,sum)>1 & apply(new.matmut[,j],1,sum)<length(j)))
G12V.overlap.genes <- apply(new.matmut[k,j],1,function(x){fisher.test(as.numeric(G12V),as.numeric(x),alternative="greater")$p.value})
G12V.exclusive.genes <- apply(new.matmut[k,j],1,function(x){ fisher.test(as.numeric(G12V),as.numeric(x),alternative="less")$p.value})

G12C <- ifelse(KRAS_LUAD=="G12C",1,0)
k <- names(which(apply(new.matmut,1,sum)>1 & apply(new.matmut,1,sum)<401))
G12C.REST.overlap.genes <- apply(new.matmut[k,],1,function(x){fisher.test(as.numeric(G12C),as.numeric(x),alternative="greater")$p.value})
G12C.REST.exclusive.genes <- apply(new.matmut[k,],1,function(x){ fisher.test(as.numeric(G12C),as.numeric(x),alternative="less")$p.value})

G12V <- ifelse(KRAS_LUAD=="G12V",1,0)
k <- names(which(apply(new.matmut,1,sum)>1 & apply(new.matmut,1,sum)<401))
G12V.REST.overlap.genes <- apply(new.matmut[k,],1,function(x){fisher.test(as.numeric(G12V),as.numeric(x),alternative="greater")$p.value})
G12V.REST.exclusive.genes <- apply(new.matmut[k,],1,function(x){ fisher.test(as.numeric(G12V),as.numeric(x),alternative="less")$p.value})

j <- which(KRAS_LUAD %in% c("G12C","G12V"))
G12C.G12V <- ifelse(KRAS_LUAD[j]=="G12C",1,0)
k <- names(which(apply(new.matmut[,j],1,sum)>1 & apply(new.matmut[,j],1,sum)<length(j)))
G12C.G12V.overlap.genes <- apply(new.matmut[k,j],1,function(x){fisher.test(as.numeric(G12C.G12V),as.numeric(x),alternative="greater")$p.value})
G12C.G12V.exclusive.genes <- apply(new.matmut[k,j],1,function(x){ fisher.test(as.numeric(G12C.G12V),as.numeric(x),alternative="less")$p.value})

# save these into .rnk files for input into the GSEA java preranked test
setwd("/gluster/home/cferte/FELLOW/cferte/KRAS_Analysis/biological_info_meaning/GSEA_mutations_files/")

#G12C and G12V vs WT
foo <- as.data.frame(cbind(names(G12C.overlap.genes),as.numeric(-log10(as.numeric(G12C.overlap.genes)))))
foo <- foo[-which(foo$V1=="KRAS"),]
write.table(foo,file="G12C.WT.genesoverlap.rnk",row.names=FALSE,col.names=FALSE,quote=FALSE,sep="\t")

foo <- as.data.frame(cbind(names(G12C.exclusive.genes),as.numeric(-log10(as.numeric(G12C.exclusive.genes)))))
foo <- foo[-which(foo$V1=="KRAS"),]
write.table(foo,file="G12C.WT.genesexclusive.rnk",row.names=FALSE,col.names=FALSE,quote=FALSE,sep="\t")

foo <- as.data.frame(cbind(names(G12V.overlap.genes),as.numeric(-log10(as.numeric(G12V.overlap.genes)))))
foo <- foo[-which(foo$V1=="KRAS"),]
write.table(foo,file="G12V.WT.genesoverlap.rnk",row.names=FALSE,col.names=FALSE,quote=FALSE,sep="\t")

foo <- as.data.frame(cbind(names(G12V.exclusive.genes),as.numeric(-log10(as.numeric(G12V.exclusive.genes)))))
foo <- foo[-which(foo$V1=="KRAS"),]
write.table(foo,file="G12V.WT.genesexclusive.rnk",row.names=FALSE,col.names=FALSE,quote=FALSE,sep="\t")

#G12C vs G12V
foo <- as.data.frame(cbind(names(G12C.G12V.overlap.genes),as.numeric(-log10(as.numeric(G12C.G12V.overlap.genes)))))
write.table(foo,file="G12C.G12V.genesoverlap.rnk",row.names=FALSE,col.names=FALSE,quote=FALSE,sep="\t")

foo <- as.data.frame(cbind(names(G12C.G12V.exclusive.genes),as.numeric(-log10(as.numeric(G12C.G12V.exclusive.genes)))))
write.table(foo,file="G12C.G12V.genesexclusive.rnk",row.names=FALSE,col.names=FALSE,quote=FALSE,sep="\t")

# G12C and G12V vs REST
foo <- as.data.frame(cbind(names(G12C.REST.overlap.genes),as.numeric(-log10(as.numeric(G12C.REST.overlap.genes)))))
foo <- foo[-which(foo$V1=="KRAS"),]
write.table(foo,file="G12C.REST.genesoverlap.rnk",row.names=FALSE,col.names=FALSE,quote=FALSE,sep="\t")

foo <- as.data.frame(cbind(names(G12C.REST.exclusive.genes),as.numeric(-log10(as.numeric(G12C.REST.exclusive.genes)))))
foo <- foo[-which(foo$V1=="KRAS"),]
write.table(foo,file="G12C.REST.genesexclusive.rnk",row.names=FALSE,col.names=FALSE,quote=FALSE,sep="\t")

foo <- as.data.frame(cbind(names(G12V.REST.overlap.genes),as.numeric(-log10(as.numeric(G12V.REST.overlap.genes)))))
foo <- foo[-which(foo$V1=="KRAS"),]
write.table(foo,file="G12V.REST.genesoverlap.rnk",row.names=FALSE,col.names=FALSE,quote=FALSE,sep="\t")

foo <- as.data.frame(cbind(names(G12V.REST.exclusive.genes),as.numeric(-log10(as.numeric(G12V.REST.exclusive.genes)))))
foo <- foo[-which(foo$V1=="KRAS"),]
write.table(foo,file="G12V.REST.genesexclusive.rnk",row.names=FALSE,col.names=FALSE,quote=FALSE,sep="\t")

