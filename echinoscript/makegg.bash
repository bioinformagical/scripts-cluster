#for i in 1 2 4 5 6 7 8 9 10 11 12 13 14 19 20 21 22 23 
#do
#	grep ">" bj${i}tri.fasta > bj${i}tri.tmp
#	sed  -e 's/^>//g' bj${i}tri.tmp > bj${i}.nofront.txt
#	tr '\n' ' ' < bj${i}.nofront.txt > bj$i.1line.txt
#	(echo -n 'bj$i}: '; cat bj$i.1line.txt ) > bj${i}tri.gg
#	#sed  -e 's/^/bj$itri:/' bj$i.1line.txt > bjitri.gg 
#	#cp bj${i}.header.faa bj${i}.header.faa.orig
#	#sed s/-/\|/g bj${i}.header.faa > bj${i}.temp.fa
#	#mv bj${i}.temp.fa bj${i}.header.faa
#done
#
#for file in $(seq -f 'bj%gtri.fasta' 1 2) $(seq -f 'bj%gtri.fasta' 4 14) $(seq -f 'bj%gtri.fasta' 19 23)
#do
#	TMPFILE=$(mkstemp)
#	TITLE=$(basename $file .fasta)
#	OUTPUT=${TITLE}.gg
#
#	grep '^>' $file > $TMPFILE
#
#	printf "${TITLE}: " > $OUTPUT
#	while read line
#		printf "%s " ${line#>} >> $OUTPUT
#	do
#	done < $TMPFILE
#	printf "\n" >> $OUTPUT
#
#	rm $TMPFILE
#done


