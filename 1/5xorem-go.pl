#!/usr/bin/perl -w

use strict;

my $key="ICE";
my @k=split(//,$key);
my $i=0;

while(<>)
{
	my @l=split(//);
	foreach my $c (@l){
		printf("%02x", ord($k[$i])^ord($c));
		$i++;
		$i=0 if($i>=length($key));
	}
}
print "\n";
