open( ASM, "</lustre/home/rreid2/old/gm/assembly2/sp3/oases_asm.afg" );
while (<ASM>) {
    if (/\{RED/) { $reads++ }
    elsif (/{SCF/) {
      #i need to ignore TLEs in scaffolds b/c they are contigs
      $inScf=1;
    }
    elsif (/\{CTG/) { $inScf=0;$getCtgID = 1; }
    elsif (/iid:(\d+)/){if($getCtgID){$ctgID=$1;$getCtgID=0; }}
    elsif (/\{TLE/) { if(!$inScf){$inTile = 1; $tiles++;}}
    elsif (/src/) {
        if ($inTile) { 
          $src++;
          if($readSrc{$_}){
            warn "seen $_ before"
          }
          $readSrc{$_} = $ctgID;
          $inTile = 0; 
        }
    }
}
foreach my $read(keys %readSrc){
  print "read $read is in contig ".$readSrc{$read}."\n";
}
print "looks like I used ".scalar(keys %readSrc)." out of $reads total reads\n";
