#!/usr/bin/python

import re
import sys
import die
#import rogersSlidingWindowCount
#from rogersTheta import getSegregatingSites 
#from rogersTheta import getA

######      This will read in a master freq table file and calculate the theta per 10KB window and it will slide 
	#   Let's add how often we see a segregating site (defined by does snp have a 1 and a 0 in the numerator).  Write a new table.
	#  For given set of rays, we needs # of segsites, n is equal to number of strain columns we have, e.g. green = 10 flies
	#   a = 1/1+1/2_1/3,,,,1/n-1
#	USAGE:		 python /users/rreid2/scripts/python/confirmThetaUsingRogerCode.py pos-green-cols-freqall.txt outname 
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
tmp=sys.argv[2]
tmparray=tmp.split(".")
front=tmparray[0]
### THE output file .......
outname = front+"-10KWindow-wtheta.txt"
#outname = front+"-temp.txt"
outfile = open(outname, 'w')
print "OUr outname is ",outname

def gettheta(s,a):
        theta=s/a
        return theta

def getA(n):
        a=0.0
        i=1
        while i < n:
                a+=(1.0/i)
                i+=1
        return a


#####  Printing a Header
#outfile.write("Chrom-Position\t0/0\t0/1\t0/2\t1/0\t2/0\t1*/1\t1/1\t1/2\t2/2")
#outfile.write("Chrom\tStart\tStop\tn\ta\t#segSites\tw-theta\tNumberOfHaplotypes")
outfile.write("Chrom\tStart\tStop\tmeanpi/window\tS/window\tavg-NumberOfHaplotypes\tmin-NumberOfHaplotypes\tmax-NumberOfHaplotypes")
outfile.write("\n")

#####    Read in Master table, 
filemaster = open(sys.argv[1])
startcount=0
stopcount=10000
window=10000.0
currentcount=0
chrom = "2L"
tenkarray = []
## Thow away header
header=filemaster.readline()


window=10000
prevchrom="foo"
MeanPi=0.0
startwindow=0
stopwindow=startwindow+window
S=0.0
windownum=[1]
tmp=0
for line in filemaster:
    A=line.split()
    site=A[0].split('-')
    chrom=site[0]
    pos=int(site[1])
    freq=A[-2]
    #print freq
    foo=freq.split('/')
    numerator=int(foo[0])
    denominator=int(foo[1])
    n=float(denominator)
    k=float(numerator)
    a=0
    #for i in range(1,n):
    #	a=a+1/i
    a=getA(n)
    if chrom==prevchrom:
	if startwindow<= pos and pos <=stopwindow:
            if n>1:
                MeanPi=MeanPi+ k*(n-k)/(n*(n-1)/2)
                #print k, n
		#print MeanPi
		S=S+1/a
                windownum.append(n)
		#print n
		#tmp += 1
		#if tmp%10 == 0:
		#	print S,a,n
        else:
		#print prevchrom, startwindow, MeanPi/window, S/window, sum(windownum)/len(windownum), min(windownum), max(windownum)
		
		outfile.write("%s\t%i\t%i\t%.4f\t%.4f\t%.4f\t%i\t%i\n"% (prevchrom, startwindow,stopwindow, MeanPi/window, S/window, sum(windownum)/len(windownum), min(windownum), max(windownum)))
		#sys.exit(0)
		MeanPi=0
            	S=0
            	windownum=[1]
            	startwindow=startwindow+1000
		stopwindow=startwindow+window
            	if n>1:
              		MeanPi=MeanPi+ k*(n-k)/(n*(n-1)/2)
              		windownum.append(n)
              		S=S+1/a
    else:
    	#print prevchrom, startwindow, MeanPi/window, S/window , sum(windownum)/len(windownum),min(windownum), max(windownum)
	outfile.write("%s\t%i\t%.4f\t%.4f\t%.4f\t%i\t%i\n"% (prevchrom, startwindow, MeanPi/window, S/window, sum(windownum)/len(windownum), min(windownum), max(windownum)))
	MeanPi=0
        startwindow=0
	stopwindow=startwindow+window
        S=0
        windownum=[1]
        if n> 1:
            	MeanPi=MeanPi+k*(n-k)/(n*(n-1)/2)
           	S=S+1/a
            	windownum.append(n)
    	prevchrom=chrom







"""
summedSegSites=0.0
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
	### make copy of ray, remove column 1 and the last 2 columns.
	snpcallray=ray[1:-3]
	numhap=int(ray[-1])
	n=numhap
	issegsite=getSegregatingSites(snpcallray)
	i=1
	a=0
	while i < n-1:
        	tmp=float(i)
        	a+=(1.0/tmp)
        	i+=1
	

	#fraction=ray[-1].split('/')
	#print ray[-1]
	#numerator=int(fraction[0])
	#denominator=int(fraction[1])
	#if denominator > 1:
	#	print denominator
	#n = float(denominator)
	#k = float(numerator)
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
			summedSegSites += issegsite
			#summedSegSites = summedSegSites/a
		#tenkarray.append(ray)	
		#print ray[1:]
	elif	(pos > stopcount):
		outfile.write("%s\t"%chrom)
		outfile.write("%i\t"%startcount)
		outfile.write("%i\t"%stopcount)
		if n> 1:
			summedSegSites += issegsite
			#summedSegSites = summedSegSites/a
		#customWindow=pos-startcount
		#meanpi=summedPi/customWindow
		wtheta=summedSegSites/(a*window)
		outfile.write("%i\t"%n)
		outfile.write("%f\t"%a)
		outfile.write("%i\t"%summedSegSites)
		outfile.write("%f\t"%wtheta)
		outfile.write("%i\n"%numhap)	
		#printray=GetSNPTallies(tenkarray)
		#print printray
		#for cb in printray:
		#	outfile.write("%s\t"%cb)
		#outfile.write(printray)
		#outfile.write("\n")
		#del tenkarray[:]
		#tenkarray.pop(0)
		#tenkarray.append(ray)
		#print len(tenkarray)
		#print tenkarray[0]
		#startcount=int(tenkarray[0][0].split("-")[1])
		#while (startcount < (pos-10000)):
		#	tenkarray.pop(0)
		#startcount=int(tenkarray[0][0].split("-")[1])
		#startcount=pos-10000
		startcount+=1000
		#print startcount
		stopcount=startcount + window
		summedSegSites=0
		#print " Start, stop and Size of the tenkarray: %i,%i, %i " %(startcount, stopcount, len(tenkarray))
#print "The Final OVERALL count is ",count,"\n"
"""
print "done\n"



def getA(n):
	a=1.0
	i=0
	while i < n-1:
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

