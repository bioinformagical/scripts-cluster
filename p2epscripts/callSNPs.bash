
echo 'Usage = callSNPs.bash yourfasta.fasta yoursamfileHeader' 

fasta=$1
samfile=$2

samtools import $fasta $samfile  $samfile.bam
samtools view -F 0x04 -b $samfile.bam > $samfile.rmd.bam
samtools sort $samfile.rmd.bam $samfile.rmd.bam.srt
samtools index $samfile.rmd.bam.srt.bam
 
samtools mpileup -ugf $fasta $samfile.bam.srt.bam | bcftools view -bvcg - > $samfile.bcf
bcftools view $samfile.bcf > $samfile.vcf

