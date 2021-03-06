# Justin Guinney and Charles Ferté
# Sage Bionetworks
# Jan 23 2013

# yield information about the pathways associated with the mutations that cooccur 
# or ar mutually exclusive with G12V


source("/home/jguinney/projects/h3/analysis/JGLibrary.R")
gsets <- load.gmt.data("/home/jguinney/projects/h3/resources/c2.cp.v3.1.symbols.gmt")
pid_gsets <- gsets[grepl("^PID_",names(gsets))]


test.mut.pathways <- function(MUTtbl, gsets, classFactor, countThreshold=1){
  stopifnot(ncol(MUTtbl) == length(classFactor))
  
  sapply(gsets, function(gset){
    idxs <- rownames(MUTtbl) %in% gset
    if(sum(idxs) < 10){ return (NA)}
    cs <- colSums(MUTtbl[idxs,])
    stat <- factor(cs >= countThreshold )
    if(length(levels(stat)) < 2){ return(NA) }
    fisher.test(stat,classFactor,alternative="greater")$p.value
  })
}

load("/home/cferte/FELLOW/cferte/KRAS_Analysis/KRAS_LUAD.RData")
load(file="/home/cferte/FELLOW/cferte/KRAS_Analysis/MATMUT_GENE_LUAD.RData")

mask <- names(KRAS_LUAD)
tmp <- MATMUT_GENE_LUAD[, mask]
tmp <- tmp[-which(rownames(tmp)=="KRAS"),]

factor <- rep("REST", ncol(tmp))
factor[colnames(tmp) %in% names(KRAS_LUAD)[KRAS_LUAD %in% "G12V"]] <- "G12V"

R <- test.mut.pathways(MUTtbl=tmp, gsets=gsets, classFactor=factor(factor))
sort(R)[1:10]

# compute the permutation test
R.null <- replicate(10000,test.mut.pathways(MUTtbl=tmp, gsets=gsets, factor(factor)[sample(ncol(tmp))]))

emp.pval <- c()
res <- sapply(names(R),function(x){
  emp.val <- c(emp.pval,length(which(R.null[x,]<R[x]))/10000)
})

G12V.REST.fisher <- res

sort(G12V.REST.fisher)[1:10]
