from __future__ import division

InFile=open("/nobackup/rogers_research/rob/inbred/vcf-megatable/allelefrequency/pos-green-cols-freqall.txt", 'r')
header=InFile.readline()
header2=InFile.readline()

window=10000
prevchrom="foo"
MeanPi=0
mywindow=0
S=0
windownum=[1]
for line in InFile:
    A=line.split()
    site=A[0].split('-')
    chrom=site[0]
    pos=int(site[1])
    freq=A[12]
    foo=freq.split('/')
    numerator=int(foo[0])
    denominator=int(foo[1])
    n=denominator
    k=numerator
    a=0
    for i in range(1,n):
        a=a+1/i
    if chrom==prevchrom:
        if mywindow<= pos and pos <=mywindow + window: 
            if n>1:
                MeanPi=MeanPi+ k*(n-k)/(n*(n-1)/2)
                S=S+1/a
                windownum.append(n)
        else:
            print prevchrom, mywindow, MeanPi/window, S/window, sum(windownum)/len(windownum), min(windownum), max(windownum)
            MeanPi=0
            S=0
            windownum=[]
            mywindow=mywindow+window
            if n>1:
              MeanPi=MeanPi+ k*(n-k)/(n*(n-1)/2)
              windownum.append(n)
              S=S+1/a
    else:
        print prevchrom, mywindow, MeanPi/window, S/window , sum(windownum)/len(windownum),min(windownum), max(windownum)
        MeanPi=0
        mywindow=0
        S=0
        windownum=[]
        if n> 1:
            MeanPi=MeanPi+k*(n-k)/(n*(n-1)/2)
            S=S+1/a
            windownum.append(n)
    prevchrom=chrom


