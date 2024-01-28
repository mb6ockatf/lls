#!/usr/bin/perl
use strict;
use warnings;

# Get command line arguments
my $file_path = $ARGV[0];
my $pattern = $ARGV[1];

# Check if file_path and pattern are provided
if (not defined $file_path or not defined $pattern) {
   print "Usage: ./main.pl <filename> <string>\n";
   exit(1);
}

open my $file, '<', $file_path or die "Cannot open file: $!\n";

# Read each line from the file and print if it contains the pattern
while (my $line = <$file>) {
    chomp($line);
    if ($line =~ /$pattern/) {
        print "$line\n";
    }
}

close $file;
