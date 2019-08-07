#!/usr/bin/python

import re
import sys
import die
from collections import OrderedDict 


#########################3    convertNot2TPM-averaged.py ----This will read in SRA 12 gene expression table from James       #########################################
##########################################################################################################
######
######		This will read in a 12 column gene expression table from James. And we will read in a TIAG GFF file.  
	# 	We are going to:
	#		1. read the GFF file into a HASH, key = geneID, value = geneLength 
	#		2.  Iterate through the gene expression file. If > 0, we will write the line but first we average the replicates!!!
	#		3. Write results to table.
	#	USAGE:		 python /users/rreid2/scripts/python/convertNot2TPM-averaged.py /nobackup/banana_genome/tomato/publicData/cornell-other/ITAG3.2_gene_models.gff /nobackup/banana_genome/tomato/snps-12genesXpressed/12lyco-expressed-2.txt geneNagMalM82-snps.txt 
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
outname = "snpsAnd-NOTPMsButRawCounts.txt"
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
		elif "ID=mRNA" not in line:
			continue
		else:
			linearray = line.split()
			chromosome=linearray[0]
			start=int(linearray[3])
			stop=int(linearray[4])
			geneid=linearray[8].replace(';',':').replace('.',':').split(":")[1]
			idstuff=line.split('Note=')
			#print linearray[8:]
			######## There is one annotation  that lacks!!!  ###### So this is workaround:
			if ("Solyc11g067050" not in idstuff):
				print idstuff[1]
				annot=idstuff[1]
				#length=int(idstuff[8])
				gffhash[geneid]=annot
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
				genesof12hash[geneid]=line
			else:
				nogenesfile.write(geneid)
				nogenesfile.write("\n")
#sys.exit()

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
			ray=genesof12hash[geneid].split()
			ray.pop(0)
			###   Exploit this header:   L1dry   L1germ  L1plus  L1self  L2dry   L2germ  L2plus  L2self  L3dry   L3germ  L3plus  L3self
			dry=(float(ray[0])+float(ray[4])+float(ray[8]))/3.0
			germ=(float(ray[1])+float(ray[5])+float(ray[9]))/3.0
			plus=(float(ray[2])+float(ray[6])+float(ray[10]))/3.0
			self=(float(ray[3])+float(ray[7])+float(ray[11]))/3.0
			outfile.write("{:.1f}".format(dry))
			outfile.write("\t")
			outfile.write("{:.1f}".format(germ))
			outfile.write("\t")
			outfile.write("{:.1f}".format(plus))
			outfile.write("\t")
			outfile.write("{:.1f}".format(self))
			outfile.write("\t")
			outfile.write(gffhash[geneid])
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
	

