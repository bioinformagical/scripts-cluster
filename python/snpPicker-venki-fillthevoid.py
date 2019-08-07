#!/usr/bin/python

import re
import sys
import die

#########################3           SNP PICKER VERSION FILL THE VOID        #########################################
##########################################################################################################
######
######			Same as Version 2 but now we output it in a venki friendly format.
######		This will read in a VCF file (previously filtered to be in gene region and not a REPEAT), a reference genome, teh reference genome GFF file and total Num of NT in genome. 
	# 	We are going to:
	#		1. Determine how many snps for each chr. (submethod needing genome size and chromosome sequence.)
	#		2. Calulate interval along chromsome. Take first gene as #1, the next will whatever gene is downstream from the next interval.
	#			2a. Get midpoint of gene via GFF ref. And then get +-50BP od sequence from that position.
	#		3. Write results to table.
	#	We read in a GFF file as a list that we need to iterate through for each SNP call and see if it is in the range.
	#	USAGE:		 python /home/rreid2/scripts/python/snpPicker-venki.py $chr ./${chr}.vcf /nobackup/banana_genome/snppicker/pahang-ref-just11chr.fna   331812599 /nobackup/banana_genome/snppicker/master/just7-14-locations.txt /nobackup/banana_genome/snppicker/master/3master.txt-just7-14.txt 489
Prefix = ""
print sys.argv[1]
print "The number of sys.argv given were; ",len(sys.argv),"\n"
if (len(sys.argv) > 8 or len(sys.argv) < 8 ):
	sys.exit("Exiting due to wrong # of arguments !!! ")
	#die.Die("Must specify 1 ARG. LaST ARG WAS ",str(sys.argv)," ")
	#Prefix = sys.argv[2]

###  Read kaas FPKM  Table in, parse the line to get kaas id and FPKM and add them to a dict.
genomesize = sys.argv[4]
print sys.argv[1]
tmp=sys.argv[1]
foundcount=int(sys.argv[7])
tmparray=tmp.split(".")
front=tmparray[0]
### OUtfile
outname = front+"-thevoid.txt"
outfile = open(outname, 'w')
heatname=front+"-heatmap.txt"
heatfile = open(heatname, 'w')
#countname=front+"-v2-snppicked-rejected.txt"
#countfile=open(countname, 'w')
counthash = {}

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



###  A dict of SNP alredy chosen as they are GOI
#####   Open just 3master.txt-just7-14.txt into a big Dict for checking later if our SNP pick matches
just7hash={}
with open(sys.argv[6]) as aafile:
	for line in aafile:
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
			just7hash[coord]=1
## End of loading our SNP already chosen.

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

chro=sys.argv[1].strip()
print chro
print len(fastahash[chro][0])
fasta=fastahash[chro][0]

def getIntervals(genomesize, fastasize,foundcount):
        #fastasize=len(fastasequence)
	print "The Fasta size is ",fastasize
	print "The genome size is ",genomesize
        percent=fastasize/genomesize
	print "The percent is ",percent
        ## We are calling 15,000 snps. So this is pulling a pecent of those
        numofSNPs=int(15000*percent)
	numofSNPs=numofSNPs-foundcount
	print "the num of snps needed to retrieve is ",numofSNPs
        return(numofSNPs)


#####     Now Calculate the number of SNPS we still need to fetch
## The chr we want from the comand line
numofsnps = getIntervals(float(genomesize), len(fastahash[chro][0]),foundcount)

print "The number of SNPs needed is  ",numofsnps


####  Open originail vcf, chr01.vcf and get the cord and get DESC and put that into a hash for when we write out later.
file1 = open(sys.argv[2])
deschash={}
snp1hash={}
snp2hash={}
while 1:
        isaussie=0
	line = file1.readline()
	line = line.strip('\n')
	if len(line) == 0:
		 print "Done loading VCF file !!"
		 break
	pattern=re.compile("^#")
	if pattern.match(line):
		continue
	else:
		linearray = line.split()
		coord=linearray[1]
		id=chro+"-"+coord
		snp1=linearray[3]
		snp2=linearray[4]
		infocol=linearray[12]
		infocol2=" ".join(linearray[12:-3])
		deschash[id]=infocol2
		snp1hash[id]=snp1
		snp2hash[id]=snp2

###### Go find the proper SNP / Gene for each interval
currentpos = 0
fasta=fastahash[chro][0]
is2ndgene = 0
isaussie = 0
ncbihash = {}
ncbi=""
### OPen our just7-14file and keep only the correct chromosome Number. Add each entry to a list. Sort the list afterwards.  
file7 = open(sys.argv[5])
chrolist= []
chromap={}
while 1:
	line = file7.readline()
	line = line.strip('\n')
	if len(line) == 0:
	 	print "Done loading VCF file !!"
		break
	linearray = line.split()
	#print line
	coord=int(linearray[0].split("-")[1])
	#chomosome=linearray[0].split("-")[0]
	if chro in linearray[0]:
		chrolist.append(coord)
		chromap[coord]=line
chrolist.sort()
#print chrolist
#sys.exit()

#Now we need to collect some via the intervals previously determined.
## interval = len(chrolist)/numofsnps
interval = len(chrolist)
print "We will grab a SNP from the chrlist SNP list at every",interval, " elements in the list"
interval = interval/int(numofsnps)
print "We will grab a SNP from the chrlist SNP list at every",interval, " elements in the list"
i=0
##sys.exit()
smallchro=[]
while i < len(chrolist):
	#print i," and chrolist is ",chrolist[i]
	smallchro.append(chrolist[i])
	i += (interval/3)
print "the size of the small list = ",len(smallchro)
#sys.exit()
	
##### Now for every element in the chrolist write out venki style the results
for i in range(len(smallchro)):
	newid=chro+"-"+str(smallchro[i])
	#print newid
	if newid in just7hash:
		print "found a hit in the just7hash"
		continue
	if newid not in snp1hash:
		continue
	if newid not in snp2hash:
		continue
	if newid not in deschash:
		continue
	snp1=snp1hash[newid]
	snp2=snp2hash[newid]
	pos=int(smallchro[i])
	start=pos-60
	stop=pos+60
	startfas=fasta[start:(pos-1)]
	stopfas=fasta[pos:stop]
	infocol2=deschash[newid]


	#nad then PRINT IT ALL
	outfile.write(newid)
	outfile.write("\tSNP\t")
	outfile.write(startfas)
        outfile.write("[")
        outfile.write(snp1)
        outfile.write("/")
        outfile.write(snp2)
        outfile.write("]")
        outfile.write(stopfas)
        outfile.write("\t")
        outfile.write(chro)
        outfile.write("\t")
        outfile.write(str(smallchro[i]))
        outfile.write("\tPahang Musa Acuminata\tGATK\tVer1\tForward\tMusa Acuminata\tTRUE\t")
        outfile.write(infocol2)
	outfile.write("\n")
	heatfile.write(chromap[smallchro[i]])
	heatfile.write("\n")

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
	

