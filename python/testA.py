



def getA(n):
	a=0.0
       	i=1
       	while i < n:
       		a+=(1.0/i)
       		i+=1
       	return a

n=10

a1=getA(n)
print "My way = %f"% a1

a2=0.0
i=0.0
#for i in range(1,n):
while i < (n-1):
	i += 1
	a2=a2+1/i
	print a2
	print i
print "Her way = %f"% a2

