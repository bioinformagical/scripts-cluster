#!/usr/bin/python

from __future__ import division
import re
import sys
import die


######      This will read in a column table file and calculate the allele frequency (numerator and denominator) for each SNP. For a given set of columns, we then calcullate pie.  
	#   Chrom position homo freq   heterofreq
#	USAGE:		 python /users/rreid2/scripts/python/rogersPieCalc.py ./orange-col.txt
####				subgroups-col.txt is a file that contains only 1 subgroup (e.g. all d.sants) Plus chrom-pos as 1st column.. 
Prefix = ""
print sys.argv[1]
print "The number of sys.argv given were; ",len(sys.argv),"\n"
if (len(sys.argv) > 2 or len(sys.argv) < 2 ):
	sys.exit("Exiting due to wrong # of arguments !!! ")
	#die.Die("Must specify 1 ARG. LaST ARG WAS ",str(sys.argv)," ")
	#Prefix = sys.argv[2]

###  Read Table in, parse the line.
file1 = open(sys.argv[1])
print sys.argv[1]
tmp=sys.argv[1]
tmparray=tmp.split(".")
front=tmparray[0]
### Load hash with chrom-position
outname = front+"-pie.txt"
outfile = open(outname, 'w')

def GetSNPTallies(tenkarray):
        ##      Make the line we need for printing
        ## 	0/0	0/1	0/2	"1/0"	"2/0"	"1*/1"	"1/1"	"1/2"	"2/2"   
	##	0	1	2	3	4	5	6	7	8	
        returnray=[0,0,0,0,0,0,0,0,0,0,0,0]
	#print len(tenkarray)
	#print tenkarray
        #for j in range(0,len(tenkarray)):
	#for j in range(0,20):
	#j=0
	#while j < len(tenkarray):
	numerator=0
	denominator=0
	for j in tenkarray:
		#print j
		#sys.exit()
                if ("0/0" in j[1]):
                        returnray[0]+=1
                        #numerator+=1
                if ("0/1" in j[1]):
                        returnray[1]+=1
                        numerator+=1
                if ("0/2" in j[1]):
                        returnray[2]+=1
                        denominator+=1
                if ("1/0" in j[1]):
                        returnray[3]+=1
                        numerator+=1
		if ("2/0" in j[1]):
			returnray[4]+=1
			denominator+=1
		if ("1*/1" in j[1]):
			returnray[5]+=1
		if ("1/1" in j[1]):
			returnray[6]+=1
			numerator+=1
		if ("1/2" in j[1]):
			returnray[7]+=1
			denominator+=1
		if ("2/2" in j[1]):
		 	returnray[8]+=1
			denominator+=1

	
	returnray[9]=numerator
	returnray[10]=denominator
	returnray[11]=len(tenkarray)
        return returnray



#####  Printing a Header
#outfile.write("Chrom-Position\t0/0\t0/1\t0/2\t1/0\t2/0\t1*/1\t1/1\t1/2\t2/2")
#outfile.write("\n")

#####    Read in Master table, 
filemaster = open(sys.argv[1])
startcount=0
stopcount=10000
currentcount=0
chrom = "2L"
tenkarray = []
## Write header to file and add freq and theta
header=filemaster.readline()
outfile.write("%s\t"%header)
outfile.write("all-freq\tall-freq-AsFraction\tw-theta\t")

while 1:
	line = filemaster.readline()
	line = line.strip('\n')
	if len(line) == 0:
		print "Done reading master file, We out !!"
		break
	#write original values to line
	outfile.write("%s\t"%line)
	ray=line.split()
	pos=ray[0]
	ray.pop(0)
	length=len(ray)
	N=2.0*length
	#outfile.write("%s\t"%pos)
	
	numerator=0.0
	denominator=0.0
	for j in ray:
        	if ("0/1" in j):
                        denominator+=1
        	if ("0/2" in j):
                        denominator+=2
                #if ("1/0" in j):
                #        numerator+=1
                #if ("2/0" in j):
                #        denominator+=1
                if ("1*/1" in j):
			numerator+=1
			denominator+=1
                if ("1/1" in j):
                        numerator+=1
			denominator+=1
                if ("1/2" in j):
                        numerator+=1
			denominator+=2
                if ("2/2" in j):
                        numerator+=1
			denominator+=2
	pie=0.0
	if denominator == 0 or denominator == 1:
		pie=0.0
	else:
		pie=numerator*(denominator-numerator)
		bottom=(denominator*(denominator-1))/2
		pie=pie/bottom
	#print "Total homo = %i"%totalhomo
	#print "Total hetero = %i"%denominator
	#a=1.0
	#for i in xrange(len(ray)):
#		tmp=float(i)+1.0
#		a+=(1.0/tmp)
#	theta=freq/a
	#print "Total homo = %f"%homofreq
	#outfile.write("%f\t"%freq)
	outfile.write("%i/%i\t"% (numerator,denominator))
	#heterofreq=denominator/N
	#print "Total hetero = %f"%heterofreq
	outfile.write("%f\n"%pie)

print "done\n"


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

