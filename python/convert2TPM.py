#!/usr/bin/python

import re
import sys
import die
from collections import OrderedDict 


#########################3    convert2TPM.py ----This will read in SRA 12 gene expression table from James       #########################################
##########################################################################################################
######
######		This will read in a 12 column gene expression table from James. And we will read in a TIAG GFF file.  
	# 	We are going to:
	#		1. read the GFF file into a HASH, key = geneID, value = geneLength 
	#		2.  Iterate through the gene expression file. If > 0, we will calculate TPM and write the line
	#		3. Write results to table.
	#	USAGE:		 python /users/rreid2/scripts/python/convert2TPM.py /nobackup/banana_genome/tomato/publicData/cornell-other/ITAG3.2_gene_models.gff /nobackup/banana_genome/tomato/snps-12genesXpressed/12lyco-expressed-2.txt geneNagMalM82-snps.txt 
Prefix = ""
print sys.argv[1]
print "The number of sys.argv given were; ",len(sys.argv),"\n"
if (len(sys.argv) > 4 or len(sys.argv) < 4 ):
	sys.exit("Exiting due to wrong # of arguments !!! ")
	#die.Die("Must specify 1 ARG. LaST ARG WAS ",str(sys.argv)," ")
	#Prefix = sys.argv[2]

###  making some OUTPUT FILES.
print sys.argv[1]
tmp=sys.argv[1]
tmparray=tmp.split(".")
front=tmparray[0]
### OUtfile
outname = "snpsAnd-TPMs.txt"
#sys.exit()
outfile = open(outname, 'w')
countname = "genes-unloved.txt"
nogenesfile = open(countname, 'w')
#locatename=front+"locations.txt"
#locatefile = open(locatename, 'w')

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
with open(sys.argv[1]) as afile:
	for line in afile:
		line =  line.strip()
		if not line:
			continue
		pattern=re.compile("^#")
		if pattern.match(line):
			continue
		elif "ID=gene" not in line:
			continue
		else:
			linearray = line.split()
			chromosome=linearray[0]
			start=int(linearray[3])
			stop=int(linearray[4])
			idstuff=linearray[8].replace(';',':').replace('=',':').split(':')
			geneid=idstuff[6].split('.')[0]
			length=int(idstuff[8])
			gffhash[geneid]=length
			
			#print str(geneid)
			#print length
#sys.exit("Temp leaving, checking stuff")


### Read in the 12 Gene expressions table and check if each line exists in the gffhash
###  Also get the RPK Scaling value, which is sum of each Column after we divide by length ofGENE
RPKSCALE=[0,0,0,0,0,0,0,0,0,0,0,0]
genesof12hash={}
with open(sys.argv[2]) as genefile:
	for line in genefile:
		line =  line.strip()
		if not line:
			continue
		pattern=re.compile("^gene")
		if pattern.match(line):
			print line
			continue
		else:
			linearray = line.split()
			geneid=linearray[0].split('.')[0]
			#print geneid
			linearray.pop(0)
			if geneid in gffhash:
				length=gffhash[geneid]
				i=0
				while i < len(linearray):
					cpm=int(linearray[i])
					RPK=float(cpm/length)
					RPKSCALE[i] = float(RPK) + float(RPKSCALE[i])
					#print RPK
					#print RPKSCALE[i-1]
					linearray[i]=RPK
					i += 1
				genesof12hash[geneid]=linearray
			else:
				nogenesfile.write(geneid)
				nogenesfile.write("\n")
#sys.exit()
##Scaling RPK to / 1,000,000
i=0
while i < len(RPKSCALE):
	RPKSCALE[i]= float(RPKSCALE[i]/1000000)
	print str(RPKSCALE[i])
	i += 1

####  Let's read each line of the SNP file, find the gene ID that matches, calc the TPM and print the line

with open(sys.argv[3]) as snpfile:
	for line in snpfile:
		line =  line.strip()
		if not line:
			continue
		linearray = line.split()
		geneid=linearray[0].split('.')[0]
		outfile.write(line)
		outfile.write("\t")
		if geneid in genesof12hash:
			print geneid
			i = 0
			while i < len(genesof12hash[geneid]):
				tpm=float(genesof12hash[geneid][i])/RPKSCALE[i]
				outfile.write(str(tpm))
				outfile.write("\t")
				i += 1
			outfile.write("\n")
		else:
			outfile.write("We FOUND no GENE ID MATCH in Gene Expression Data\n")
			
		


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
	

