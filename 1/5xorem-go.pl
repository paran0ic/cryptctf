#!/usr/bin/perl -w

use strict;

my $key=shift;
#"ICE";
my $opt='';
$opt=shift;
if($opt){
	if($opt =~ m/h/i){
		print "usage: command KEY option\nv - verbose vv- more verbose s- no space in alphabet\n";
		exit 0;
	}
}
my @k=split(//,$key);
my $i=0;
my $pos=0;
while(<>)
{
	my @l=split(//);
	foreach my $c (@l){
		printf("%02x", ord($k[$i])^ord($c));
		$i++;
		$i=0 if($i>=length($key));
		if($pos++>35){
			print "\n" ;
			$pos=0;
		}
	}
}

print "\n";
