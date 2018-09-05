#!/usr/bin/perl -w

use MIME::Base64;
use strict;
 use utf8;
 no utf8;
 
#my $key=shift;
#"ICE";
my $debug=0;
my $space=0;
my $opt='';
$opt=shift;
if($opt){
	if($opt =~ m/h/i){
		print "usage: command KEY option\nv - verbose vv- more verbose s- no space in alphabet\n";
		exit 0;
	}
	if($opt =~ m/v/i){
		$debug=1;
	}
	if($opt =~ m/vv/i){
		$debug=2;
	}
	if($opt =~ m/s/i){
		$space=1;
	}
	if($opt =~ m/ss/i){
		$space=2;
	}
	if($opt =~ m/sss/i){
		$space=3;
	}
	if($opt =~ m/ssss/i){
		$space=4;
	}
}

#die "$space $debug";
my $line = join("",<>);


my $bin=decode_base64( $line );
#print toHex($bin);
#$bin="abcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabc";


my %hHD;

my $binlen=length($bin);
#die $bin;
my @bytes=split(//,$bin);
for(my $klen=2; $klen<40; $klen++){
	my $blok1='';
	my $blok2='';
	my $blok3='';
	my $blok4='';
	for(my $pos=0;$pos<$klen*14;++$pos){
		$blok1 .= $bytes[$space+$pos+$klen*0];
		$blok2 .= $bytes[$space+$pos+$klen*14];
	}
	my $hd=HammingDistance($blok1,$blok2)/length($blok1);
	if($debug==2) {print "keylen: $klen Hamming distance: $hd\n";}
	$hHD{$klen}=$hd;
#	print "$blok1\n$blok2\n\n";
	
}

#porownanie wynikow 
print "\nBest:\n";
my @keys = sort { $hHD{$a} <=> $hHD{$b} } keys(%hHD);
my @vals = @hHD{@keys};

for(my $i=0;$i<5;$i++){
	print "keylen: ".$keys[$i]. ' HammingDistance: '.$vals[$i].' '."\n"	;
}
#stats
if($debug>0){
	#for(my $i=2;$i<10;$i++){
	my $i=$keys[0];{
		my $keysize=$i; #$keys[$i];
	#$binlen = 20*$i;
		#print "KEYSIZE: $keys[$i]\n";
		for(my $keypos=0; $keypos<$keysize;$keypos++){
			for(my $pos=0;$pos<$binlen-$keypos;$pos+=$keysize){
				print(toHex($bytes[$pos+$keypos]));
			}
			print "\n";
		}
	}
}
#print "\n\n".HammingDistance("this is a test","wokka wokka!!!")."\n";


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


