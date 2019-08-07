#for file in $(seq -f 'bj%gtri.fasta' 1 2) $(seq -f 'bj%gtri.fasta' 4 14) $(seq -f 'bj%gtri.fasta' 19 23)
set -eux
for file in tmp.fasta
do
        TMPFILE=$(mktemp)
        TITLE=$(basename $file .fasta)
        OUTPUT=${TITLE}.gg

        grep '^>' $file > $TMPFILE
        
        printf "${TITLE}: " > $OUTPUT
        while read line
	do
		printf "%s " ${line#>} >> $OUTPUT
        done < $TMPFILE
        printf "\n" >> $OUTPUT
        
        rm $TMPFILE
done

