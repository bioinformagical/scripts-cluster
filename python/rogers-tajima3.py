#!/usr/bin/python

from __future__ import division
import re
import sys
#import die
import math

######      This will read in a theta table file and a meanpi table and then calculate the differences for each 10K window. 
######		What is V??  And how do we calc that?  Guessing that is variance... 
	#   Chrom position homo freq   heterofreq
#	USAGE:		 python /users/rreid2/scripts/python/rogers-tajima3.py mayotte-pie.txt 
###				subgroups-col.txt is a file that contains only 1 subgroup (e.g. all d.sants) Plus chrom-pos as 1st column.. 
Prefix = ""
print sys.argv[1]
print "The number of sys.argv given were; ",len(sys.argv),"\n"
if (len(sys.argv) > 2 or len(sys.argv) < 2 ):
	sys.exit("Exiting due to wrong # of arguments !!! ")
	#die.Die("Must specify 1 ARG. LaST ARG WAS ",str(sys.argv)," ")
	#Prefix = sys.argv[2]

###  Read Table in, parse the line.
thetamaster = open(sys.argv[1])
print sys.argv[1]
tmp=sys.argv[1]
tmparray=tmp.split("-")
front=tmparray[0]
front2=front.split('/')
### Load hash with chrom-position
#origID=front2[-1].split('-')[1]
outname = front+"-tajima3.txt"
#outfile = open("/nobackup/rogers_research/RobMods/"+outname, 'w')
outfile = open(outname, 'w')

def geta1(n):
	i=1
	a1=0.0
	while i < n:
		a1 += (1/i)
		i += 1
	return a1

def geta2(n):
	i=1
	a2=0.0
	while i < n:
		a2 += (1/i)
		i += 1
	return a2
def getb1(n):
	b1=0.0
	b1=(n+1)/(3*(n-1))
	return b1

def getb2(n):
	b2=0.0
	top=2*(n*n + n +3)
	bottom=(9*n)*(n-1)
	b2 = top/bottom
	return b2

def getc1(a1,b1):
	return (b1-(1/a1))

def getc2(a1,a2,n,b2):
	c2=0.0
	c2=b2-((n+2)/(a1*n))+(a2/a1)
	return c2

def gete1(a1,c1):
	return c1/a1

def gete2(a1,a2,c1):
	return (c2/(a1*a1*a2))



## Write header to file and add freq and theta
header=thetamaster.readline()
header=header.strip('\n')
headray=header.split()
outfile.write("%s\t%s\t%s\t"% (headray[0],headray[1],headray[2]))
outfile.write("wtheta\tmeanpi\td\tD\n")

while 1:
	linew = thetamaster.readline()
	linew = linew.strip('\n')
	if len(linew) == 0:
		print "Done reading master file, We out !!"
		break

	#write original values to line
	#outfile.write("%s\t"%line)
	rayw=linew.split()
	wtheta=float(rayw[4])*10000
	n=float(rayw[-3])
	meanpi=float(rayw[3])*10000
	print (" n = %f"%n)
	if n < 1.000001:
		continue
	#sys.exit()
	a1=geta1(n)
	a2=geta2(n)
	b1=getb1(n)
	b2=getb2(n)
	c1=getc1(a1,b1)
	c2=getc2(a1,a2,n,b2)
	e1=gete1(a1,c1)
	e2=gete2(a1,a2,c1)
	#print "a1,a2,b1,b2,c1,c2,e1,e2,wtheta: %s %s %s %s %s %s %s %s %s"% (a1,a2,b1,b2,c1,c2,e1,e2,wtheta)
	S=wtheta*a1
	d=meanpi-wtheta

	### D= meanpi-wtheta   /   SQRT(|e1*S+e2*S*(S-1)|)
	Dtop=meanpi-wtheta
	Dbottom=1.0
	if S > 1:
		Dbottom=math.sqrt((e1*S)+(e2*S*(S-1)))
	D=0.0
	print "S,d,Dtop,Dbottom: %s %s %s %s"% (S,d,Dtop,Dbottom)
	if Dbottom > 0.0:
		D=Dtop/Dbottom
	outfile.write("%s\t%s\t%s\t"% (rayw[0],rayw[1],rayw[2]))
	outfile.write("%f\t%f\t%f\t%f\n"% (wtheta,meanpi,d,D))

print "done\n"



