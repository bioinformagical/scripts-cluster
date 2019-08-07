#!/usr/bin/python

import re
import sys
import die
from collections import OrderedDict 


#########################3    calcAF-AndfilterDP-fromVCF.py ----Rewrite a VCF file only including entries that have DP > 50 and is heterzygous (AF not 0 or 1)        #########################################
##########################################################################################################
######
######		This will read in a VCF file  and some sort of master file.  
	# 	We are going to:
	#		1. read the VCF file into a HASH, key = cord, value = AF value from the INFO section of the VCF
	#		2.  Iterate through the master file. Check if coord exists in af hash. Write out a binary file and write out the AF value to a AF file.
	#		3. Write results to table.
	#	USAGE:		 python /users/rreid2/scripts/python/countsnpsInGenes.py /nobackup/banana_genome/tomato/align/nagcarlang-gatk-test.vcf /nobackup/banana_genome/tomato/publicData/cornell-other/ITAG3.2_gene_models.gff
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
outname = front+"-inGENE.txt"
#sys.exit()
outfile = open(outname, 'w')
countname = front+"-gene-snps-count.txt"
countfile = open(countname, 'w')
locatename=front+"locations.txt"
locatefile = open(locatename, 'w')

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
gffcounthash={}
locationhash={}
orderedhash=OrderedDict()
with open(sys.argv[2]) as afile:
	for line in afile:
		line =  line.strip()
		if not line:
			continue
		pattern=re.compile("^#")
		if pattern.match(line):
			continue
		elif "ID=exon" not in line:
			continue
		else:
			linearray = line.split()
			chromosome=linearray[0]
			start=int(linearray[3])
			stop=int(linearray[4])
			idstuff=linearray[8].replace(';',':').replace('=',':').split(':')
			mrna=idstuff[5]
			mrna=mrna[:-2]  ##Removing the .1 off the end because that would be an exon, not the mRNA
			#print mrna
			while start < stop:
				coord=chromosome+"-"+str(start)
				gffhash[coord]=mrna
				start += 1
			gffcounthash[mrna]=0
			orderedhash[mrna]=[chromosome,start,mrna]
#sys.exit("Temp leaving, checking stuff")


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
			posmarker=float(pos)/100000
			if coord in gffhash:
				print coord
				tmp = gffcounthash[gffhash[coord]]
				tmp += 1
				gffcounthash[gffhash[coord]] = tmp

				#if gffhash[coord] in locationhash:
			#		print  locationhash[gffhash[coord]
			#	else:
			#		locationhash[gffhash[coord]]=1
				outfile.write(line)
				outfile.write("\t")
				outfile.write(gffhash[coord])
				outfile.write("\n")
#sys.exit()
count0=0
count1=0
count2plus=0
for key in orderedhash:
	count=gffcounthash[key]
	pos=orderedhash[key][1]
	pos=pos/100000
	if count == 0:
		count0 += 1
	elif count == 1:
		count1 += 1
		locatefile.write(str(orderedhash[key][0]))
		locatefile.write("\t")
		locatefile.write(str(orderedhash[key][1]))
		locatefile.write("\t")
		locatefile.write(str(pos))
		locatefile.write("\t")
		locatefile.write(key)
		locatefile.write("\t")
		locatefile.write(str(gffcounthash[key]))
		locatefile.write("\n")
	elif count > 1:
		count2plus += 1
		locatefile.write(str(orderedhash[key][0]))
		locatefile.write("\t")
		locatefile.write(str(orderedhash[key][1]))
		locatefile.write("\t")
		locatefile.write(str(pos))
		locatefile.write("\t") 
		locatefile.write(key)
		locatefile.write("\t")
		locatefile.write(str(gffcounthash[key]))
		locatefile.write("\n")
	else:
		sys.exit("Something went wrong!")
	countfile.write(key)
	countfile.write("\t")
	countfile.write(str(gffcounthash[key]))
	countfile.write("\n")
print count0
print count1
print count2plus

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
	

