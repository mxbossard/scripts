#!/usr/bin/perl
use strict;
use File::Copy;
use File::Basename;

my $path = $ARGV[0];
my $outputdir = $ARGV[1];
open(CLASSPATH, "<$path") or die "can't open $path";

my @lines = <CLASSPATH>;
close(CLASSPATH);

foreach my $line (@lines) {
    if ($line =~ m/<classpathentry kind="lib" path="(.*?)".*?\/>/) {
        print "copying".$1."\n";
        copy($1, $outputdir.basename($1)) or print "failed to copy $1\n";
    }
}
