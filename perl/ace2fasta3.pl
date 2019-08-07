#!/usr/bin/perl -w

# Author: Björn Canbäck
# License: No license.

# Part of the Sheffield package.
# Usage: see ace2fasta.pl -h
# The ace format is explained in:
# http://www.phrap.org/consed/distributions/README.16.0.txt
# in section ACE FILE FORMAT
# This script has only been tested on GS Reference Mapper ace files.
# It is semi-prepared for running in mod-perl (also remove die).

use strict;
use File::Path qw/make_path/;
use Getopt::Long;
$Getopt::Long::ignorecase = 0;	# Make options case sensitive

my ($AceFile,$RemoveFile,$directory,$Force,$consensus,$contig,$contig_file,
    $reference,$minsize,$unpadded,$gap,$pad_character,$version_number);

my @ARGVcopy = @ARGV; # GetOptions destroys @ARGV;

# Program name, must be assigned before GetOptions
my $program;
($program = $0) =~ s#.*/##;
my $version = '2.1.1';

GetOptions('infile=s' => \$AceFile,
	   'remove=s' => \$RemoveFile,
	   'directory=s' => \$directory,
	   'Force' => \$Force,
	   'consensus' => \$consensus,
	   'Contig' => \$contig,
	   'output-file=s' => \$contig_file, 
	   'n' => \$reference,
	   'minimum=i' => \$minsize,
	   'unpadded' => \$unpadded,
	   'gap' => \$gap,
	   'pad-character=s' => \$pad_character,
	   'version' => \$version_number,
	   'help' => \&usage 
	  );

# Print version
if ( $version_number ) {
    print "$program version $version\n";
    exit(1);
}

# Check files and options
usage() if ! $AceFile;
if ( ! -e $AceFile ) {
    print STDERR "ERROR: The input file should be given in the format -i infile. See $program -h.\n";
    exit(1);
}
if ( $RemoveFile && ! -e $RemoveFile ) {
    print STDERR "ERROR: The file with contigs not to include should be given in the format \"-r file\". See $program -h.\n";
    exit(2);
}
if ( $contig_file && ! $contig ) {
    print STDERR "ERROR: If -o is set, -C must also be set. See $program -h.\n";
    exit(3);
}
if ( $consensus && $contig ) {
    print STDERR "ERROR: -c and -C can not be set at the same time. See $program -h.\n";
    exit(4);
}
if ( $gap && $unpadded ) {
    print STDERR "ERROR: -g and -u can not be set at the same time. See $program -h.\n";
    exit(4);
}

$directory ||= 'FastaAlignment'; # Default
if ( ! $Force ) {
    if ( -d $directory ) {
	print STDERR "ERROR: The output directory already exists. Please, specify a new one with -d or use -F to force a potential overwrite. See $program -h.\n";
	exit(5);
    }
    File::Path::make_path($directory) or die $!;
} else {
    File::Path::make_path($directory) or die $! if ! -d $directory;
}

# Set defaults
$reference = 'reference.fas';
$Force ||= 0;
$consensus ||= 0;
$contig ||= 0;
$contig_file ||= '';
$minsize ||= 0;
$unpadded ||= 0;
$pad_character ||= '*';
# Set default output contig file 
if ( $contig && ! $contig_file ) { # Output of contig sequences
    if ( $gap ) {
	$contig_file = 'contig.fasta';
    } elsif ( $unpadded ) {
	$contig_file = 'contig.unpadded.fasta';
    } else {
	$contig_file = 'contig.padded.fasta';
    }
}

# Make an array of option values
my @options = ($AceFile,$RemoveFile,$directory,$Force,$consensus,$contig,$contig_file,$minsize,$unpadded,$pad_character);

# Make an array of initialize counter_values, these are:
# 0: $number_of_ace_contigs, Remains 0 if something is wrong
# 1: $number_of_ace_reads, Remains 0 if something is wrong
# 2: $number_of_invalid_contigs, -m switch
# 3: $number_of_invalid_reads, -m switch
# 4: $number_of_removed_contigs, -r switch
# 5: $number_of_removed_reads, -r switch
my @numbers = (0,0,0,0,0,0);

# Make a hash with contigs to remove as keys
my (%remove);
if ( $RemoveFile ) {
    if ( ! -e $RemoveFile ) {
	print STDERR "ERROR: The file with contigs to remove should be given in the format -r removefile. See $program -h.\n";
	exit(6);
    }
    open(REMOVE,$RemoveFile) or die $!;
    while ( my $line = <REMOVE> ) {
	$line =~ s/\s.*//;
	$remove{$line} = 1;
    }
    close(REMOVE) or die $!;
}

open(REF,">$directory/$reference") or die if $reference;
# Parse the ace file with either of two subroutines
my $aref_numbers;
if ( $contig ) {
    $aref_numbers = print_contig_file(\@options,\@numbers,\%remove);
} else {
    $aref_numbers = print_fasta_files(\@options,\@numbers,\%remove);
}
close(REF) or die if $reference;

# Print info to screen
my @new_numbers = @$aref_numbers;
my $number_of_output_contigs = $new_numbers[0] - $new_numbers[2] - $new_numbers[4];
my $number_of_output_reads = $new_numbers[1] - $new_numbers[3] - $new_numbers[5];
print STDERR <<HERE;

Content in ace-file:                     $new_numbers[0] contigs representing $new_numbers[1] reads.
Rejected contigs due to size limit (-m): $new_numbers[2] contigs representing $new_numbers[3] reads.
Contigs removed by user (-r):            $new_numbers[4] contigs representing $new_numbers[5] reads.
Contigs in output files:                 $number_of_output_contigs contigs representing $number_of_output_reads reads.

The program was run as:
HERE
print STDERR join(' ',$0,@ARGVcopy), "\n\n";
print STDERR "Output directory is $directory\n\n" if ! $contig;
print STDERR "Output file is $directory/$contig_file\n\n" if $contig;

# SUBROUTINES

sub print_contig_file {

    my ($aref_options,$aref_numbers,$href_remove) = @_;
    my ($AceFile,$RemoveFile,$directory,$Force,$consensus,$contig,$contig_file,$minsize,$unpadded,$pad_character) = @$aref_options;
    my ($number_of_ace_contigs,$number_of_ace_reads,$number_of_invalid_contigs,$number_of_invalid_reads,$number_of_removed_contigs,$number_of_removed_reads) = @$aref_numbers;
    my %remove = %$href_remove;
    
    # Parse ace file
    my (@line,$valid_contig,$ContigSequence,$ContigID,$name);
    open(ACE,$AceFile) or die $!;
    open(CONTIG,">$directory/$contig_file") or die $!;
    while ( my $line = <ACE> ) {

	chomp $line;

	if ( $line =~ m/^RD / ) {
	    $number_of_ace_reads++;
	    next;
	}
	      
	if ( $valid_contig ) {
	    if ( $line =~ m/./ ) {
		$ContigSequence .= $line;
	    } else {
		$valid_contig = 0;
		if ( $unpadded ) {
		    if ( $pad_character eq '*' ) {
			$ContigSequence =~ tr/*//d;
		    } else {
			$ContigSequence =~ s/$pad_character//go;
		    } 
		}
		$ContigSequence =~ tr/\*\-\.//d if $gap;
		print CONTIG "$ContigID\n$ContigSequence\n";
	    }
	    next;
	}

	if ( $line =~ m/^CO / ) {

	    $number_of_ace_contigs++;

	    # Reset for each contig
	    $ContigSequence = '';
	    $valid_contig = 0;
	    @line = split(' ',$line);
	
	    # Probably no software outputs reverse contig sequences?
	    if ( $line[5] ne 'U' ) {
		print STDERR "ERROR: This script doesn't support contig sequences in reverse direction. If you need this, mail me.\n";
		exit(7);
	    }

	    # Contigs to remove because of too small contig size
	    if ( $minsize && $line[3] < $minsize ) {
		$number_of_invalid_contigs++; 
		$number_of_invalid_reads += $line[3];
		$valid_contig = 0;
		next; 
	    }

	    # Contigs to remove because of the user supplied remove file 
	    if ( defined($remove{$line[1]}) ) {
		$number_of_removed_contigs++;
		$number_of_removed_reads += $line[3];
		$valid_contig = 0;
		next;
	    }

	    $valid_contig = 1;
	    #($name = $line[1]) =~ tr/:/_/;
	    $ContigID = ">$line[1] nseq=$line[3] length=$line[2]";
	    next;
	}
    }
    close(ACE) or die $!;
    close(CONTIG) or die $!;
    my @new_numbers = ($number_of_ace_contigs,$number_of_ace_reads,$number_of_invalid_contigs,$number_of_invalid_reads,$number_of_removed_contigs,$number_of_removed_reads);
    return(\@new_numbers);
}

  sub print_fasta_files {

      my ($aref_options,$aref_numbers,$href_remove) = @_;
      my ($AceFile,$RemoveFile,$directory,$Force,$consensus,$contig,$contig_file,$minsize,$unpadded,$pad_character) = @$aref_options;
      my ($number_of_ace_contigs,$number_of_ace_reads,$number_of_invalid_contigs,$number_of_invalid_reads,$number_of_removed_contigs,$number_of_removed_reads) = @$aref_numbers;
      my %remove = %$href_remove;

      my (@line,$ContigSequence,$ContigID,$name,$output_file);
      my ($found1,$found2,$pad5,$pad3,$pad5Length,$start);
      my ($ContigName,$ContigLength);
      my ($ReadName,$ReadLength,$ReadSequence,$UnpaddedReadSequence);
      my (@ContigPosition,@sequence,@PadPositions);
      my $number_of_contig_reads = 0; # Internal count
      my $number_of_parsed_reads = 0; # Internal count
      my $valid_contig = 0;	# A switch

      # The more common matches are placed at the top
      open(ACE,$AceFile) or die $!;
      while ( my $line = <ACE> ) {

	  chomp $line;

	  $found1 = 0 if $found1 && $line !~ m/./; # Ends contig sequence
	  $found2 = 0 if $found2 && $line !~ m/./; # Ends read sequence

	  # Skip uninformative lines
	  next if $line !~ m/./;;
	  next if $line =~ m/^\d/;;
	  next if $line =~ m/^DS/;;

	  ### Reads ###

	  # The number of reads in the file doesn't always correspond to the
	  # specification in the AS line (the first line).
	  $number_of_ace_reads++ if $line =~ m/^RD /; 
	  if ( $valid_contig ) {
	      if ( $found1 ) { 
		  $ContigSequence .= $line;
	      }
	      if ( $line =~ m/^AF / ) {
		  @line = split(' ',$line);
		  $ContigPosition[$number_of_contig_reads] = $line[3];
		  $number_of_contig_reads++;
		  next;
	      }
	      if ( $line =~ m/^RD / ) {
		  $found2 = 1;
		  @line = split(' ',$line);
		  $ReadName = $line[1];
		  next;
	      }
	      if ( $found2 ) {
		  $ReadSequence .= $line; 
		  next;
	      }
	      if ( $line =~ m/^QA / ) {
		  @line = split(' ',$line);
		  $ReadLength = $line[4] - $line[3] + 1;
		  $pad5Length = $ContigPosition[$number_of_parsed_reads] + $line[3] - 2;
		  $pad5 = '-' x $pad5Length; 
		  $pad3 = '-' x ($ContigLength - $ReadLength - $pad5Length);
	    
		  $ReadSequence = $pad5 . substr($ReadSequence,$line[3] - 1,$ReadLength) . $pad3;
		  if ( $unpadded ) {
		      if ( scalar(@PadPositions) != 0 ) {
			  $UnpaddedReadSequence = substr($ReadSequence,0,$PadPositions[0]);
			  for (my $i = 0; $i < $#PadPositions; $i++ ) {
			      $start = $PadPositions[$i] + 1;
			      $UnpaddedReadSequence  .= substr($ReadSequence,$start,$PadPositions[$i+1] - $start);
			  }
			  $UnpaddedReadSequence .= substr($ReadSequence,$PadPositions[$#PadPositions] + 1);
			  $ReadSequence = $UnpaddedReadSequence
		      }
		  }
		  #$ReadName =~ tr/:/_/;
		  $ReadSequence =~ tr/\*\-\.//d if $gap;
		  print OUT '>', $ReadName, "\n", $ReadSequence, "\n";
		  print REF '>', $ReadName, "\n", $ReadSequence, "\n" if $reference && $number_of_parsed_reads == 0;
		  $ReadSequence = '';
		  $number_of_parsed_reads++;
		  next;
	      }
	  }

	  ### Contigs ###

	  # In the ace file contigs come before the reads
	  if ( $line =~ m/^CO / ) {

	      $number_of_ace_contigs++;

	      # Reset for each contig
	      $ContigSequence = '';
	      close(OUT) or die $! if $valid_contig;
	      $valid_contig = 0;
	      $number_of_contig_reads = 0;
	      $number_of_parsed_reads = 0;
	      @line = split(' ',$line);
	
	      # Probably no software outputs reverse contig sequences?
	      if ( $line[5] ne 'U' ) {
		  print STDERR "ERROR: This script doesn't support contig sequences in reverse direction. If you need this, mail me.\n";
		  exit(8);
	      }

	      # Contigs to remove because of too small contig size
	      if ( $minsize && $line[3] < $minsize ) {
		  $number_of_invalid_contigs++; 
		  $number_of_invalid_reads += $line[3];
		  $valid_contig = 0;
		  next; 
	      }
	      # Contigs to remove because of the user supplied remove file 
	      if ( defined($remove{$line[1]}) ) {
		  $number_of_removed_contigs++;
		  $number_of_removed_reads += $line[3];
		  $valid_contig = 0;
		  next;
	      }
	      $ContigName = $line[1];
	      $ContigLength = $line[2];
	      $valid_contig = 1;

	      if ( $gap ) {
		  $output_file = "$ContigName.fasta";
	      } elsif ( $unpadded ) {
		  $output_file = "$ContigName.unpadded.fasta";
	      } else {
		  $output_file = "$ContigName.padded.fasta";
	      }
	      open(OUT,">$directory/$output_file") or die $! if ! $contig;
	      if ( $consensus ) {
		  ($name = $line[1]) =~ tr/:/_/;
		  $ContigID = ">$name nseq=$line[3] length=$line[2]" if $consensus;
	      }
	      $found1 = 1;
	      next;
	  }
	
	  if ( $valid_contig && $line =~ m/^BQ/ && ($consensus || $unpadded || $contig) ) {
	      if ( $unpadded ) {
		  @PadPositions = ();
		  @sequence = split(//,$ContigSequence);
		  for ( my $i = 0; $i < @sequence; $i++ ) {
		      push(@PadPositions,$i) if $sequence[$i] eq $pad_character;
		  }
		  # tr/ is faster then s/. Here it's assumed that * is
		  # the most common case of pad character.
		  if ( $pad_character eq '*' ) {
		      $ContigSequence =~ tr/*//d;
		  } else {
		      $ContigSequence =~ s/$pad_character//go;
		  } 
	      }
	      $ContigSequence =~ tr/\*\-\.//d if $gap;
	      print OUT "$ContigID\n$ContigSequence\n" if $consensus;
	      next;
	  }
      }
      close(OUT) or die $! if $valid_contig; # Last entry
      close(ACE) or die $!;
      my @new_numbers = ($number_of_ace_contigs,$number_of_ace_reads,$number_of_invalid_contigs,$number_of_invalid_reads,$number_of_removed_contigs,$number_of_removed_reads);
    return(\@new_numbers);
  }

sub usage {
      print STDERR <<HERE;

Description:   Creates fasta alignments from an ace file, one per unigene
               or contig or cluster. It is mainly thought for EST assemblies. 
               A file with contig names not to include may be specified with -r.
               Colons in sequence names are replaced with underscores ("_"). 

Usage:         $program -i ace_file [-r file-with-contig-names]
               [-d output-directory] [-F] [-c] [-C] [-o contig-out-file] 
               [-n] [-m] [-u] [-g] [-p pad-character] [-v] [-h]
 
Consider:      The fasta alignment format is easily converted to other
               formats by programs like clustalw or readseq.

Output files:  Default: contig1.padded.fasta, contig2.padded.fasta ...
               or (-u): contig1.unpadded.fasta, contig2.unpadded.fasta ... 
               or (-g): contig1.padded.fasta, contig2.padded.fasta ...

               Default if -C: contig.padded.fasta (default) 
                              contig.unpadded.fasta (if -u)
                              contig.unpadded.fasta (if -g)
               or a file name set by -o. 

               If -n reference.fna will be produced. All files will be 
               placed in the directory FastaAlignment or a directory 
               specified with -d.

Short options:

-i (string)    The input ace file.
-r (string)    A file with contig names which shouldn't be included in the
               output. One contig id per line.
-d (string)    Output directory. Default: FastaAlignment.
-F (boolean)   Force potentially overwrite of existing files.
-c (boolean)   Include the contig (consensus) sequence as the first 
               sequence in each alignment.
-C (boolean)   Only output the contig (consensus) sequences in one file.
-o (string)    The output file used for -C. Default: contig.unpadded.fasta
               or contig.padded.fasta in the directory specified with -d.
-n (string)    In addition output a file with the first read for each 
               contig. This read could represent a reference sequence if 
               the ace file is a result of a sequence capture project.
               The output file is named reference.fas.
-m (integer)   Minimum size of contig for its inclusion in the output.
               Default: 1.  
-u (boolean)   Create an unpadded alignment. This will take considerable
               more time (approx. 2 min. for 150000 sequence).
-g (boolean)   Remove gaps (*, - and .). Output will be (not aligned) 
               sequences.
-p (string)    The pad character in the ace-file, normally an asterisk
               ("*"). Default: *.
-v (boolean)   Print version number and exit.
-h (boolean)   This help.

Example usage: $program -i ace_file -d Test

HERE
      exit(9);
  }

