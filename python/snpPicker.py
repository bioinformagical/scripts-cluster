#!/usr/bin/python

import re
import sys
import die

######      This will read in a VCF file (previously filtered to be in gene region and not a REPEAT), a reference genome, teh reference genome GFF file and total Num of NT in genome. 
	# 	We are going to:
	#		1. Determine how many snps for each chr. (submethod needing genome size and chromosome sequence.)
	#		2. Calulate interval along chromsome. Take first gene as #1, the next will whatever gene is downstream from the next interval.
	#			2a. Get midpoint of gene via GFF ref. And then get +-50BP od sequence from that position.
	#		3. Write results to table.
	#	We read in a GFF file as a list that we need to iterate through for each SNP call and see if it is in the range.
	#	USAGE:		 python /home/rreid2/scripts/python/filterVCF-byRepeat-banana.py $chr ./${chr}.vcf /nobackup/banana_genome/snppicker/pahang-ref-just11chr.fna  331812599

Prefix = ""
print sys.argv[1]
print "The number of sys.argv given were; ",len(sys.argv),"\n"
if (len(sys.argv) > 5 or len(sys.argv) < 5 ):
	sys.exit("Exiting due to wrong # of arguments !!! ")
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
outname = front+"-snppicked.vcf"
outfile = open(outname, 'w')
countname=front+"-snppicked-rejected.txt"
countfile=open(countname, 'w')
counthash = {}


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
			if activechr not in fastahash:
				fastahash[activechr] = []
				print activechr
			continue
		seq = line
		fastahash[activechr].append(seq)

#sys.exit()

chro=sys.argv[1].strip()
print chro
print len(fastahash[chro][0])

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
chromintervalarray = getIntervals(float(genomesize), len(fastahash[chro][0]))

print "The size of the Interval array is ",len(chromintervalarray)," and the 6th array element is ",chromintervalarray[5]

#sys.exit()


###### Go find the proper SNP / Gene for each interval
currentpos = 0
fasta=fastahash[chro][0]
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
		snp=linearray[4]
		infocol=linearray[10]
		pos = int(linearray[1])
		if (currentpos >= len(chromintervalarray)):
			print "We have reached the end of the interval  array"
			break
		if (int(pos) > int(chromintervalarray[currentpos])):
			#print "We are in the loop and at position ",chromintervalarray[currentpos]
			#outfile.write(line)
			#outfile.write("\t")
			start=pos-49
			stop=pos+50
			snpseq=fasta[start:stop]
			#if "N" not in  snpseq:
			outfile.write(line)
			outfile.write("\t")
			outfile.write(snpseq)
			outfile.write("\n")
			
			while (pos > int(chromintervalarray[currentpos])):
				print "currentpos is now",currentpos," and pos is ",pos
				currentpos += 1
				if (currentpos >= len(chromintervalarray)):
					print "We have reached the end of the interval  array"
					break
		else:
			start=pos-49
			stop=pos+50
			snpseq=fasta[start:stop]
			countfile.write(line)
			countfile.write("\t")
			countfile.write(snpseq)
			countfile.write("\n")
			#print "The pos was ",pos," and the current Interval is ",chromintervalarray[currentpos]
			#print "skipping Gene:",infocol

#sys.exit()

print "The Final is dine and pos ended at ",currentpos,"\n"

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
	

