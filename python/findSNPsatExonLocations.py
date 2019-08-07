#!/usr/bin/python

import re
import sys
import die

#########################3    calcAF-AndfilterDP-fromVCF.py ----Rewrite a VCF file only including entries that have DP > 50 and is heterzygous (AF not 0 or 1)        #########################################
##########################################################################################################
######
######		This will read in a VCF file  and some sort of master file.  
	# 	We are going to:
	#		1. read the VCF file into a HASH, key = cord, value = AF value from the INFO section of the VCF
	#		2.  Iterate through the master file. Check if coord exists in af hash. Write out a binary file and write out the AF value to a AF file.
	#		3. Write results to table.
	#	USAGE:		 python /users/rreid2/scripts/python/findSNPsatExonLocations.py /nobackup/banana_genome/tomato/align/nagcarlang-gatk-test.vcf /nobackup/banana_genome/tomato/publicData/cornell-other/ITAG3.2_gene_models.gff
Prefix = ""
print sys.argv[1]
print "The number of sys.argv given were; ",len(sys.argv),"\n"
if (len(sys.argv) > 3 or len(sys.argv) < 3 ):
	sys.exit("Exiting due to wrong # of arguments !!! ")
	#die.Die("Must specify 1 ARG. LaST ARG WAS ",str(sys.argv)," ")
	#Prefix = sys.argv[2]

###  making some OUTPUT FILES.
print sys.argv[1]
tmp=sys.argv[1]
tmparray=tmp.split(".")
front=tmparray[0]
### OUtfile
outname = front+"-inEXON.txt"
#sys.exit()
outfile = open(outname, 'w')

#######  Sub method getIntervals
def getIntervals(genomesize, fastasize,foundcount):
        #fastasize=len(fastasequence)
        print "The Fasta size is ",fastasize
        print "The genome size is ",genomesize
        percent=fastasize/genomesize
        print "The percent is ",percent
        ## We are calling 15,000 snps. So this is pulling a pecent of those
        numofSNPs=int(15000*percent)-int(foundcount)
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
#######   End of getIntervals



###  A dict of A GFF file 
gffhash={}
with open(sys.argv[2]) as afile:
	for line in afile:
		line =  line.strip()
		if not line:
			continue
		pattern=re.compile("^#")
		if pattern.match(line):
			continue
		elif "exon" not in line:
			continue
		else:
			linearray = line.split()
			chromosome=linearray[0]
			start=int(linearray[3])
			stop=int(linearray[4])
			while start < stop:
				coord=chromosome+"-"+str(start)
				gffhash[coord]=line
				start += 1

### Read in the VCF and check if each line exists in the gffhash
with open(sys.argv[1]) as vcffile:
	for line in vcffile:
		line =  line.strip()
		if not line:
			continue
		pattern=re.compile("^#")
		if pattern.match(line):
			continue
		else:
			linearray = line.split()
			chrom=linearray[0]
			pos=linearray[1]
			coord=chrom+"-"+pos
			if coord in gffhash:
				print coord
				outfile.write(line)
				outfile.write("\t")
				outfile.write(gffhash[coord])
				outfile.write("\n")
#sys.exit()

print "The Final is done "

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
	

