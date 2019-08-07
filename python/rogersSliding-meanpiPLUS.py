#!/usr/bin/python

import re
import sys
import die
#import rogersSlidingWindowCount
#from rogersTheta import getSegregatingSites 
#from rogersTheta import getA

######      This will read in a master table file and calculate the frequency of SNPs per 10KB window and it will slide 
	#   Let's add how often we see each type of SNP call (0/1, 2,2, 1*/1), etc.   As a new table.
#	USAGE:		 python /users/rreid2/scripts/python/rogers-slidingWindowCount.py pos-green-cols-freqall.txt outname 
Prefix = ""
print sys.argv[1]
print "The number of sys.argv given were; ",len(sys.argv),"\n"
if (len(sys.argv) > 3 or len(sys.argv) < 3 ):
	sys.exit("Exiting due to wrong # of arguments !!! ")
	#die.Die("Must specify 1 ARG. LaST ARG WAS ",str(sys.argv)," ")
	#Prefix = sys.argv[2]

###  Read Table in, parse the line.
file1 = open(sys.argv[1])
print sys.argv[1]
front=sys.argv[2]


### THE output file .......
outname = front+"-pie.txt"
outfile = open(outname, 'w')
print "OUr outname is ",outname

def gettheta(s,a):
        theta=s/a
        return theta

#####  Printing a Header
#outfile.write("Chrom-Position\t0/0\t0/1\t0/2\t1/0\t2/0\t1*/1\t1/1\t1/2\t2/2")
outfile.write("Chrom\tStart\tStop\tmeanPI\twtheta")
outfile.write("\n")

#####    Read in Master table, 
filemaster = open(sys.argv[1])
startcount=0
stopcount=10000
currentcount=0
chrom = "2L"
tenkarray = []
## Thow away header
header=filemaster.readline()

summedPi=0.0
summedtheta=0.0
while 1:
	line = filemaster.readline()
	line = line.strip('\n')
	if len(line) == 0:
		print "Done reading master file, We out !!"
		break
	ray=line.split()
	posray=ray[0].split("-")
	pos=int(posray[1])
	newchrom=posray[0]
	fraction=ray[-2].split('/')
	#print ray[-1]
	numhaps=int(ray[-1]) ##Calced this when we got the freq. alleles.
	a=0.0
	i=1
	##### Get a
	denominator=int(fraction[1])
	while i < denominator:
		tmp=float(i)
	        a+=(1.0/tmp)
	        i+=1
	
	numerator=int(fraction[0])
	
	#if denominator > 1:
	#	print denominator
	n = float(denominator)
	k = float(numerator)
	#check if we are at end of chromosome and start a new one if need be
	if (newchrom not in chrom):
		startcount=0
		stopcount=10000
		currentcount=pos
		chrom=newchrom
	
	#print line
	#check if we have 10K range, and if not add array to test array
	if (pos < stopcount):
		if n> 1:
			summedPi += k*(n-k)/(n*(n-1)/2)
			summedtheta += (n/a)
		#tenkarray.append(ray)	
		#print ray[1:]
	elif	(pos > stopcount):
		outfile.write("%s\t"%chrom)
		outfile.write("%i\t"%startcount)
		outfile.write("%i\t"%pos)
		meanpi=summedPi/10000
		meantheta=summedtheta/10000
		outfile.write("%f\t"%meanpi)
		outfile.write("%f\n"%meantheta)
		
		startcount += 1000
		#print startcount
		stopcount=startcount + 10000
		summedPi=0.0
		summedtheta=0.0
		if n> 1:
			summedPi += k*(n-k)/(n*(n-1)/2)
			summedtheta += (n/a)
		#print " Start, stop and Size of the tenkarray: %i,%i, %i " %(startcount, stopcount, len(tenkarray))
#print "The Final OVERALL count is ",count,"\n"
print "done\n"



def getA(n):
	a=1.0
	i=0
	while i < n:
		tmp=float(i)
		a+=(1.0/tmp)
		i+=1
	return a

def gettheta(s,a):
	theta=s/a
	return theta

def GetSNPTalliesDeprecated(tenkarray):
	## 	Make the line we need for printing
	##	cavendish       mc1     mc2     mc3     2/3 3/3 all 4 justCavendish  
	##	2389	1000	899	998	1500	
	returnray=[0,0,0,0,0,0,0,0]
	for i in range(len(tenkarray)):
		mcsums=0
		gotcavendish=0
		if ("\/" in tenkarray[i][0]):
		 	returnray[0]+=1
			mcsums+=1
		if ("\/" in tenkarray[i][1]):
			returnray[1]+=1
			mcsums+=1
		if ("\/" in tenkarray[i][2]):
			returnray[2]+=1
			mcsums+=1
		if ("\/" in tenkarray[i][3]):
			returnray[3]+=1
			gotcavendish+=1
		if (mcsums==0) and (gotcavendish==1):
			returnray[7]+=1
		elif (msums == 3) and (gotcavendish==0):
			returnray[6]+=1
		elif (msums == 2) and (gotcavendish==0):
			returnray[5]+=1
		elif (msums == 1) and (gotcavendish==0):
			returnray[4]+=1
		else:
			print >> sys.stderr, "Some error in our tenkarray: " + tenkarray[i]
			sys.exit(1)
	
		
	return returnray

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

