#!/usr/bin/python

import re
import sys
import die

#########################3           SNP PICKER VERSION GENE of INTEREST   Version 3        #########################################
##########################################################################################################
######				In Version 3, we are picking genes based on the Phanag ID, so we are feeding in a file with just pahang IDs in them.
######			Same as Version Venki but now we output it in a venki friendly format.
######				And we will write the annotations out as well , the pahang ID, the gene desc at the end as separate columns
######			And we output only ones that are in our genes of interest list that we will feed in.
######		This will read in a VCF file (previously filtered to be in gene region and not a REPEAT), a reference genome, teh reference genome GFF file and total Num of NT in genome. 
	# 	We are going to:
	#		1. Read in the genes of interest File and get the ID and read that into a hash if it matches the chr#. 
	#		2. Start to interate through the main VCF.
	#		2. Calulate interval along chromsome. Take first gene as #1, the next will whatever gene is downstream from the next interval.
	#			2a. Get midpoint of gene via GFF ref. And then get +-50BP od sequence from that position.
	#		3. Write results to table.
	#	We read in a GFF file as a list that we need to iterate through for each SNP call and see if it is in the range.
	#	USAGE:		 python ~/scripts/python/snpPicker-genesOfInterest-v3.py $chr ../../snppicker/${chr}.vcf ./combinedsebPectin-IDs.txt /nobackup/banana_genome/snppicker/chrfasta/${chr}.fna

Prefix = ""
print sys.argv[1]
print "The number of sys.argv given were; ",len(sys.argv),"\n"
if (len(sys.argv) > 5 or len(sys.argv) < 5 ):
	sys.exit("Exiting due to wrong # of arguments !!! ")
	#die.Die("Must specify 1 ARG. LaST ARG WAS ",str(sys.argv)," ")
	#Prefix = sys.argv[2]

file1 = open(sys.argv[2])
#genomesize = sys.argv[4]
print sys.argv[1]
tmp=sys.argv[1]
tmparray=tmp.split(".")
front=tmparray[0]
### OUtfile
outname = front+"-genesOfInterest.txt"
outfile = open(outname, 'w')
#countname=front+"-v2-snppicked-rejected.txt"
#countfile=open(countname, 'w')
counthash = {}

######		OPEN that Fasta file 
fasta = []
seq = ""
with open(sys.argv[4]) as aafile:
        for line in aafile:
	                line =  line.strip()
			if not line:
				continue
			if line.startswith(">"):
				activesequencename = line[1:]
				activechr =activesequencename.replace("Musa acuminata subsp. malaccensis Doubled-haploid Pahang (DH-Pahang) genomic chromosome, ","")
				#if activechr not in fastahash:
				#	fastahash[activechr] = []
				#	print activechr
				#	continue
			seq = line
			fasta = seq 

######   OPEN THAT PAHANG ID file as a BIG Dict    #####
gffArray = []
goihash = {}
seq = ""
with open(sys.argv[3]) as goifile:
        for line in goifile:
		line =  line.strip()
		if not line:
			continue
		linearray = line.split()
		desc=linearray[0]
		goihash[desc] = 1
		#print desc
#sys.exit()

chro=sys.argv[1].strip()
print chro
#print len(goihash[chro][0])

def getIntervals(genomesize, fastasize):
        #fastasize=len(fastasequence)
	print "The Fasta size is ",fastasize
	print "The genome size is ",genomesize
        percent=fastasize/genomesize
	print "The percent is ",percent
        ## We are calling 15,000 snps. So this is pulling a pecent of those
        numofSNPs=int(15000*percent)
	print "the num of snps is ",numofSNPs
        interval=int(fastasize/numofSNPs)
	print "the interval is ",interval
        count=interval
        countarray =[]
	countarray.append("0")
        while count < fastasize:
                countarray.append(str(count))
                count += interval
		#print "Count is now ",count
        return(countarray)


#####     Now Calculate the intervals for each chromsome
## The chr we want from the comand line
#chromintervalarray = getIntervals(float(genomesize), len(goihash[chro][0]))

#print "The size of the Interval array is ",len(chromintervalarray)," and the 6th array element is ",chromintervalarray[5]

#sys.exit()


###### Go find the proper SNP / Gene for each interval
currentpos = 0
#fasta=fastahash[chro][0]
is2ndgene = 0
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
		linearray = line.split()
		chomrosome=linearray[0][3:]
		coord=linearray[1]
		locus=linearray[0]+"-"+coord
		snp=linearray[3]
		snp2=linearray[4]
		#print len(snp2)," and the SNP is ",snp2
		if (len(snp) >1):
			continue
		if (len(snp2) >1):
			continue
		infocol=linearray[12]
		infocol2=" ".join(linearray[12:-3])
		#print infocol
		if "ID=" in infocol:
			tmpray=infocol.split(";")[0]
			pahang=tmpray.split("=")[1]
			#print pahang
			#sys.exit()
			#ncbi = ncbi.replace("Genbank:","")
	        	if pahang in goihash:
				print "We found a match for GOIHash:",pahang," for the line ",tmpray
				
				######## Now we Print out to file    The SNP   and remove it from GOI file
				pos = int(linearray[1])
				start=pos-60
				stop=pos+60
				startfas=fasta[start:(pos-1)]
				stopfas=fasta[pos:stop]
				snpseq=fasta[start:stop]
				print snpseq
				if len(startfas) != 59:
				        print len(startfas)
					print "OUr current position is at",pos," and thte total length of chr is:",len(fasta)
				        sys.exit('Length of SNP sequence was wrong for startfas:')
				if len(stopfas) != 60:
				        print len(stopfas)
					print "OUr current position is at",pos," and thte total length of chr is:",len(fasta)
				        sys.exit('Length of SNP sequence was wrong for stopfas:')
				chars=set('nN')
				if any((c in chars) for c in  snpseq):
					continue
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
				outfile.write(chomrosome)
				outfile.write("\t")
				outfile.write(coord)
				outfile.write("\tPahang Musa Acuminata\tGATK\tVer1\tForward\tMusa Acuminata\tTRUE\t")
				outfile.write(infocol2)
				outfile.write("\n")
				
				del goihash[ncbi]
		else:
			continue
		
		

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
	

