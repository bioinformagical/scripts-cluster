#!/usr/bin/python

import re
import sys
import die

#########################3      calcAF-fromVCF.py  Making a table from AF values in the INFO field of indie VCF files        #########################################
##########################################################################################################
######
######		This will read in a VCF file  and some sort of master file.  
	# 	We are going to:
	#		1. read the VCF file into a HASH, key = cord, value = AF value from the INFO section of the VCF
	#		2.  Iterate through the master file. Check if coord exists in af hash. Write out a binary file and write out the AF value to a AF file.
	#		3. Write results to table.
	#	USAGE:		 python /users/rreid2/scripts/python/calcAF-fromVCF.py /nobackup/banana_genome/snppicker/master/megamaster-v2.txt /nobackup/banana_genome/indieVCF/1187_S15_L004-sorted.raw.vcf
Prefix = ""
print sys.argv[1]
print "The number of sys.argv given were; ",len(sys.argv),"\n"
if (len(sys.argv) > 3 or len(sys.argv) < 3 ):
	sys.exit("Exiting due to wrong # of arguments !!! ")
	#die.Die("Must specify 1 ARG. LaST ARG WAS ",str(sys.argv)," ")
	#Prefix = sys.argv[2]

###  making some OUTPUT FILES.
print sys.argv[1]
tmp=sys.argv[2]
tmparray=tmp.split("-")
front=tmparray[0]
### OUtfile
outname = front+"-AF.txt"
#print front
front=front.split("/")[4]
outname = front+"-AF.txt"
print outname
#sys.exit()
outfile = open(outname, 'w')
heteroname=front+"-isHetero.txt"
heatfile = open(heteroname, 'w')

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



###  A dict of AF VCF 
afhash={}
with open(sys.argv[2]) as afile:
	for line in afile:
		line =  line.strip()
		if not line:
			continue
		pattern=re.compile("^#")
		if pattern.match(line):
			continue
		else:
			linearray = line.split()
			#chomrosome=linearray[0][3:]
			coord=linearray[0]+"-"+linearray[1]

			#print coord
			info=linearray[7]
			af=info.split(";")[1]
			af.replace("AF=","")
			if "," in af:
				continue	
			afhash[coord]=af
			#print " We found ",af
## End of loading our SNP already chosen.

	
##### Now for every element in the chrolist write out venki style the results
with open(sys.argv[1]) as masterfile:
	for line in masterfile:
		line =  line.strip()
		linearray = line.split()
		coord=linearray[0]
		coord.strip()
		#print coord
		afscore=0
		aftrue=0
		if coord in afhash:
			#print coord
			tmp=afhash[coord].split("=")[1]
			afscore=float(tmp)
			if (afscore < 0.8) and (afscore > 0.20):
				aftrue=1
			else:
				aftrue=0

			#nad then PRINT IT ALL
		outfile.write(coord)
		outfile.write("\t")
		if coord in afhash:
			outfile.write(str(afscore))
		else:
			outfile.write("0")
        	outfile.write("\n")
       
       		heatfile.write(coord)
        	heatfile.write("\t")
        	heatfile.write(str(aftrue))
        	heatfile.write("\n")

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
	

