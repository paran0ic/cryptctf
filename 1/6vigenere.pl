#!/usr/bin/perl -w

use MIME::Base64;
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

my $line = join("",<>);


my $bin=decode_base64( $line );
#print toHex($bin);
#$bin="abcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabc";


my %hHD;

my $binlen=length($bin);
my @bytes=split(//,$bin);
for(my $klen=1; $klen<40; $klen++){
	my $blok1='';
	my $blok2='';
	for(my $pos=0;$pos<$klen;$pos+=(1)){
		$blok1 .= $bytes[$pos];
		$blok2 .= $bytes[$pos+$klen];
	}
	my $hd=HammingDistance($blok1,$blok2)/length($blok1);
	print "keylen: $klen Hamming distance: $hd\n";
	$hHD{$klen}=$hd;
#	print "$blok1\n$blok2\n\n";
	
}






print "\n\n".HammingDistance("this is a test","wokka wokka!!!")."\n";


sub HammingDistance
{
	my @t1=split(//,shift);
	my @t2=split(//,shift);
	my $bits='';
	my $hd=0;
	for(my $i=0;$i<(scalar @t1);$i++){
		my $d=ord($t1[$i])^ord($t2[$i]);
		$bits.=sprintf("%0b",$d);
	}
	#print "\n$bits\n";
	#split(//,$bits);
	$hd = () = $bits =~ /1/g;
	return $hd;#scalar @t1;
}

sub toHex
{
	#my $b=shift;
	my $h='';
	my @l=split(//,shift);
	foreach my $b (@l){
		$h .= sprintf("%02x", ord($b));
	}
	return $h;
}


