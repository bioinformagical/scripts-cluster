#!/usr/bin/python

import re
import sys
import die

#########################3           SNP PICKER VERSION AUSSIE        #########################################
##########################################################################################################
######
######			Same as Version 2 but now we output it in a venki friendly format.
######			And we pick 1 subsequent genes at each interval but then check if it exists in the Aussie VCF file (we read in the aussie VCF as a hash)
######		This will read in a VCF file (previously filtered to be in gene region and not a REPEAT), a reference genome, teh reference genome GFF file and total Num of NT in genome. 
	# 	We are going to:
	#		1. Determine how many snps for each chr. (submethod needing genome size and chromosome sequence.)
	#		2. Calulate interval along chromsome. Take first gene as #1, the next will whatever gene is downstream from the next interval.
	#			2a. Get midpoint of gene via GFF ref. And then get +-50BP od sequence from that position.
	#		3. Write results to table.
	#	We read in a GFF file as a list that we need to iterate through for each SNP call and see if it is in the range.
	#	USAGE:		 python /home/rreid2/scripts/python/snpPicker-venki.py $chr ./${chr}.vcf /nobackup/banana_genome/snppicker/pahang-ref-just11chr.fna   331812599 /nobackup/banana_genome/aussie-snps/splitvcf/${chr}-aussie.vcf
Prefix = ""
print sys.argv[1]
print "The number of sys.argv given were; ",len(sys.argv),"\n"
if (len(sys.argv) > 6 or len(sys.argv) < 6 ):
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
outname = front+"-aussie.txt"
outfile = open(outname, 'w')
#countname=front+"-v2-snppicked-rejected.txt"
#countfile=open(countname, 'w')
counthash = {}

#####   Open Aussie file into a big Dict for checking later if our SNP pick matches
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
			coord=linearray[1]
			dp=linearray[7]
			ausshash[coord]=dp


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
is2ndgene = 0
isaussie = 0
ncbihash = {}
ncbi=""
### OPen our main VCF file and check if gene region exists for each SNP location 
while 1:
	isaussie=0
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
		#### Check is in the Aussie SNP aray ####
		if coord in ausshash:
			isaussie =1
		else:
			isaussie =0
			continue
		
		infocol=linearray[12]
		infocol2=" ".join(linearray[12:-3])
		if "Genbank:" in infocol:
			tmpray=infocol.split(",")[1]
			ncbi=tmpray.split(";")[0]
			ncbi = ncbi.replace("Genbank:","")
	        	if ncbi in ncbihash:
			#print "We found a dupe for Genbank:",ncbi," for the line ",tmpray
				is2ndgene = 0
				continue
		pos = int(linearray[1])
		#print pos
		if (currentpos >= len(chromintervalarray)):
			print "We have reached the end of the interval  array"
			break
		if (int(pos) > int(chromintervalarray[currentpos])):
			#print "We are in the loop and at position ",chromintervalarray[currentpos]
			#outfile.write(line)
			#outfile.write("\t")
			start=pos-60
			stop=pos+60
			startfas=fasta[start:(pos-1)]
			stopfas=fasta[pos:stop]
			snpseq=fasta[start:stop]
			print snpseq
			if len(startfas) != 59:
				print len(startfas)
				sys.exit('Length of SNP sequence was wrong for startfas:')
			if len(stopfas) != 60:
				print len(stopfas)
				sys.exit('Length of SNP sequence was wrong for stopfas:')
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
			outfile.write(chomrosome)
			outfile.write("\t")
			outfile.write(coord)
			outfile.write("\tPahang Musa Acuminata\tGATK\tVer1\tForward\tMusa Acuminata\tTRUE\t")
			outfile.write(infocol2)
			outfile.write("\n")
			ncbihash[ncbi]=1
			if (is2ndgene == 1):
				while (pos > int(chromintervalarray[currentpos])):
					#print "currentpos is now",currentpos," and pos is ",pos
					currentpos += 1
					if (currentpos >= len(chromintervalarray)):
						print "We have reached the end of the interval  array"
						break
				is2ndgene = 0
			else:
				is2ndgene = 1
		else:
			start=pos-49
			stop=pos+50
			snpseq=fasta[start:stop]
			#countfile.write(line)
			#countfile.write("\t")
			#countfile.write(snpseq)
			#countfile.write("\n")
			#print "The pos was ",pos," and the current Interval is ",chromintervalarray[currentpos]
			#print "skipping Gene:",infocol

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
	

