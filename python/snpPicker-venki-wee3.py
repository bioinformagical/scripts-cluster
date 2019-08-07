#!/usr/bin/python

import re
import sys
import die

#########################3           SNP PICKER VERSION wee3        #########################################
##########################################################################################################
######
######			We output it in a venki friendly format.    We add in a file that has coords in the first column. 
######		This will read in a VCF file (previously filtered to be in gene region and not a REPEAT), a reference genome, teh reference genome GFF file and total Num of NT in genome. 
	# 	We are going to:
	#			2a. Get midpoint of gene via GFF ref. And then get +-50BP od sequence from that position.
	#		3. Write results to table.
	#	We read in a GFF file as a list that we need to iterate through for each SNP call and see if it is in the range.
	#	USAGE:		 python ~/scripts/python/snpPicker-venki-wee3.py $chr /nobackup/banana_genome/snppicker/${chr}.vcf /nobackup/banana_genome/snppicker/pahang-ref-just11chr.fna   331812599 /nobackup/banana_genome/indieVCF/just7-14/merged-wee3.txt
Prefix = ""
print sys.argv[1]
print "The number of sys.argv given were; ",len(sys.argv),"\n"
if (len(sys.argv) > 6 or len(sys.argv) < 6 ):
	sys.exit("Exiting due to wrong # of arguments !!! :")
	#die.Die("Must specify 1 ARG. LaST ARG WAS ",str(sys.argv)," ")
	#Prefix = sys.argv[2]

###  Read kaas FPKM  Table in, parse the line to get kaas id and FPKM and add them to a dict.
file1 = open(sys.argv[2])
genomesize = sys.argv[4]
print sys.argv[1]
tmp=sys.argv[1]
tmparray=tmp.split(".")
front=tmparray[0]
### OUtfile
outname = front+"-venki-wee3.txt"
outfile = open(outname, 'w')
#countname=front+"-v2-snppicked-rejected.txt"
#countfile=open(countname, 'w')
counthash = {}

#####   Open COORD file of interest and use column 1 for key value for Dict for checking later if our SNP pick matches
ausshash={}
with open(sys.argv[5]) as aussiefile:
	 for line in aussiefile:
	 	line =  line.strip()
		if not line:
			continue
		pattern=re.compile("^#")
		if pattern.match(line):
			continue
		else:
			linearray = line.split()
			#chomrosome=linearray[0][3:]
			coord=linearray[0]
			#dp=linearray[7]
			ausshash[coord]=1
			#print coord
#sys.exit()			


######   OPEN THAT FASTA FILE INTO a BIG Dict    #####
gffArray = []
fastahash = {}
seq = ""
with open(sys.argv[3]) as aafile:
        for line in aafile:
		line =  line.strip()
		if not line:
			continue
		if line.startswith(">"):
			activesequencename = line[1:]
			activechr =activesequencename.replace("Musa acuminata subsp. malaccensis Doubled-haploid Pahang (DH-Pahang) genomic chromosome, ","")
			if len(activechr) == 4:
				activechr=activechr[0:3]+"0"+activechr[3:]
			if activechr not in fastahash:
				fastahash[activechr] = []
				#print activechr
			continue
		seq = line
		fastahash[activechr].append(seq)

#sys.exit()

chro=sys.argv[1].strip()
print chro
print len(fastahash[chro][0])


###### Go find the proper SNP / Gene for each interval
currentpos = 0
fasta=fastahash[chro][0]
is2ndgene = 0
isaussie = 0
ncbihash = {}
ncbi=""
### OPen our main VCF file and check if gene region exists for each SNP location 
while 1:
	line = file1.readline()
	line = line.strip('\n')
	if len(line) == 0:
	 	print "Done loading VCF file !!"
		break
	pattern=re.compile("^#")
	if pattern.match(line):
		#outfile.write(line)
		#outfile.write("\n")
		continue
	else:	
		#print line
		linearray = line.split()
		chromosome=linearray[0][3:]
		coord=linearray[1]
		locus=linearray[0]+"-"+coord
		snp=linearray[3]
		snp2=linearray[4]
		#print len(snp2)," and the SNP is ",snp2
		if (len(snp) >1):
			continue
		if (len(snp2) >1):
			continue
		
		
		#### Check is in the HASH and if so print venki like ####
		#print pos
			
		if locus in ausshash:
			#print line
			infocol=linearray[12]
			infocol2=" ".join(linearray[12:-3])
			pos = int(coord)
			#print coord
			start=pos-60
			stop=pos+60
			startfas=fasta[start:(pos-1)]
			stopfas=fasta[pos:stop]
			snpseq=fasta[start:stop]
			print snpseq
			#if len(startfas) != 59:
			#	print len(startfas)
			#	sys.exit('Length of SNP sequence was wrong for startfas:')
			#if len(stopfas) != 60:
			#	print len(stopfas)
			#	sys.exit('Length of SNP sequence was wrong for stopfas:')
			#if "N" not in  snpseq:
			outfile.write(locus)
			outfile.write("\tSNP\t")
			outfile.write(startfas)
			outfile.write("[")
			outfile.write(snp)
			outfile.write("/")
			outfile.write(snp2)
			outfile.write("]")
			outfile.write(stopfas)
			outfile.write("\t")
			outfile.write(chromosome)
			outfile.write("\t")
			outfile.write(coord)
			outfile.write("\tPahang Musa Acuminata\tGATK\tVer1\tForward\tMusa Acuminata\tTRUE\t")
			outfile.write(infocol2)
			outfile.write("\n")

#sys.exit()

print "The Final is done and pos ended at ",currentpos,"\n"

def search(values, searchFor,fpkm):
	for k in values:
        	for v in values[k]:
	    		if searchFor in v:
				return max(k,fpkm)
	return None


def GetSize(Label):
	Fields = Label.split(";")
	for Field in Fields:
		if Field.startswith("size="):
			return int(Field[5:])
	print >> sys.stderr
	print >> sys.stderr, "Size not found in label: " + Label
	sys.exit(1)

def getIntervals(genomesize, fastasequence):
	fastasize=len(fastasequence)
	percent=fastasize/genomesize
	## We are calling 15,000 snps. So this is pulling a pecent of those
	numofSNPs=int(15000*percent)
	interval=fastasize/numofSNPs
	count=interval
	countarray =[]
	while (count < fastasize):
		countarray.extend(count)
		count += interval
	return(countarray)
	

