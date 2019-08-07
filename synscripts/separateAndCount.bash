for i in 1 2 3 4 6 7 
do
	taxa=species
	awk -F"|" '{ print $7 }'  seq${i}.txt.gz.adapt-phylum.mtphln.reads_map.txt > seq${i}-${taxa}.txt
	sort seq${i}-${taxa}.txt | uniq -c > seq${i}-${taxa}-count.txt
	awk '{ print $1 }' seq${i}-${taxa}-count.txt > tmp1.txt
	awk '{ print $2 }' seq${i}-${taxa}-count.txt > tmp2.txt 
	paste tmp2.txt tmp1.txt > seq${i}-${taxa}-count.txt
done
