
rm(list = ls(all=TRUE));
setwd("/Users/rreid2/gm/deseq");

# Running Deseq script
source("http://www.bioconductor.org/biocLite.R")
biocLite("DESeq")

#
# Running Deseq on oat gene expression data from their 33 condition study... 
# Instructions for this script are here.....
# http://bioconductor.org/packages/2.8/bioc/vignettes/DESeq/inst/doc/DESeq.pdf
#


library( DESeq )

#examplefile = system.file( "/Users/rreid2/gm/deseq/blastx-all-raw-byEquals.trimmed.txt", package="DESeq" )
#examplefile

countsTable <- read.delim( "/Users/rreid2/gm/deseq/blastx-all-raw-byEquals.trimmed.txt", header=TRUE, stringsAsFactors=TRUE )

#pitching the desc column away
countsTable <- countsTable[ , -2 ]

## **** Removing the 3 columns that were bad runs... from subsequent analysis.
countsTable <- subset( countsTable, select = -c( A_strigosa3, Bam_49_23, CM1_WT3))


head( countsTable )

rownames( countsTable ) <- countsTable$id
#pitching the gene id away
countsTable <- countsTable[ , -1 ]

conds <- c( "T1", "T2", "T3", "T1", "T2", "T3", "T1", "T2", "T3", "T1", "T2", "T3", "T1", "T2", "T3", "T1", "T2", "T3", "T1", "T2", "T1", "T2", "T1", "T2", "T3", "T1", "T2", "T3", "T1", "T2" )

cds <- newCountDataSet( countsTable, conds )
head( counts(cds) )

libsizes <- c( T1=105035985,	T2=153834133,	T3=233071359,	T1=168801976,	T2=249156661,	T3=280367202,	T1=243908321,	T2=321327269,	T3=259381982,	T1=225119262,	T2=107310396,	T3=383782669,	T1=234672190,	T2=229301246,	T3=367717073,	T1=290716121,	T2=190500351,	T3=333354368,	T1=73469303,	T2=46767767,	T1=178136613,	T2=140881635,	T1=192269336,	T2=227500329,	T3=312799955,	T1=93404154,	T2=83431830,	T3=80205297,	T1=48146489,	T2=63158698 )
 sizeFactors(cds) <- libsizes[]
 
cds <- estimateSizeFactors( cds )
sizeFactors( cds )

# variance estimation (assuming that equal means have equal variance, let
# us go check !)
cds <- estimateVarianceFunctions( cds )

## This si the manual variance calculation if you so desire to do it this way.
# countValue <- 123
# baseLevel <- countValue / sizeFactors(cds)["T1b"]
# rawVarFuncForGB <- rawVarFunc( cds, "T" )
# rawVariance <- rawVarFuncForGB( baseLevel )
# fullVariance <- countValue + rawVariance * sizeFactors(cds)["T1b"]^2
# sqrt( fullVariance )

#variance plot.....
 scvPlot( cds, ylim=c(0,2) )
 scvPlot( cds, ylim=c(0,25) )
 
 #base variance functions check to follow the empirical variance....
 diagForT1 <- varianceFitDiagnostics( cds, "T1" )
 diagForT2 <- varianceFitDiagnostics( cds, "T2" )
 diagForT3 <- varianceFitDiagnostics( cds, "T3" )

#change the visual layout format to X11
x11()
#Plot Base means Vs. Base variance and hope for a straightl line.
smoothScatter( log10(diagForT1$baseMean), log10(diagForT1$baseVar) )
lines( log10(fittedBaseVar) ~ log10(baseMean),
+ diagForT1[ order(diagForT1$baseMean), ], col="red" )

#Test probabilities are uniform
par( mfrow=c(1,2 ) )
residualsEcdfPlot( cds, "T1" )
residualsEcdfPlot( cds, "T2" )

#differential expression, the -ve binomial tests
res12 <- nbinomTest( cds, "T1", "T2" )
head(res12)

res13 <- nbinomTest( cds, "T1", "T3" )
res23 <- nbinomTest( cds, "T2", "T3" )

#Plot MvA plot for above results.

plotDE <- function( res13, cutoff ) { plot(res13$baseMean,res13$log2FoldChange,log="x", pch=20, cex=.1, col=ifelse( res13$padj < cutoff, "red", "black" ));title(main="Mvs.A plot")}
plotDE( res13, 0.1 )

#get only significant genes
res12Sig <- res12[ res12$padj < .1, ]
res13Sig <- res13[ res13$padj < .1, ]
res23Sig <- res23[ res23$padj < .1, ]

#remove any lines with NA 
res12Sig <- na.omit(res12Sig)
res13Sig <- na.omit(res13Sig)
res23Sig <- na.omit(res23Sig)

#check out sig. expressed genes ORDEReD !!!!
head( res13Sig[ order(res13Sig$pval), ] )
head( res13Sig[ order( res13Sig$foldChange, -res13Sig$baseMean ), ] )

#Density of ratios: Checks that the fitted variance (red and Blue lines) matches an expected variance(grey line)
plot( density( res13$resVarA, na.rm=TRUE, from=0, to=20 ), col="red" )
lines( density( res13$resVarB, na.rm=TRUE, from=0, to=20 ), col="blue" )
xg <- seq( 0, 20, length.out=1000 ); lines( xg, dchisq( xg, df=1 ), col="grey" )

#find ratios > 15 from density plot
table( res13$resVarA > 15 | res13$resVarB > 15)

#variance stabilising transformations (VST)
vsd <- getVarianceStabilizedData( cds )

mod_lfc = (rowMeans( vsd[, conditions(cds)=="T"] ) -
+ rowMeans( vsd[, conditions(cds)=="N"] ))

lfc = res12$log2FoldChange
finite = is.finite(lfc)
table(as.character(lfc[!finite]), useNA="always")

#Heatmap
dists <- dist( t( vsd ) )
heatmap(as.matrix( dists ), symm=TRUE,scale="none",col = colorRampPalette(c("darkblue","white"))(100))


# also visualise the expression data of the top 100 differentially expressed genes.
select = order(res13$pval)[1:100]
colors = colorRampPalette(c("white","darkblue"))(100)
heatmap( vsd[select,], col = colors, scale = "none")
#For comparison, let us also try the same with the untransformed counts.
heatmap( counts(cds)[select,],col = colors, scale = "none")