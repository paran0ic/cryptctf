#!/usr/bin/perl

use strict;

my $opt=shift;



my $wagamax=0;
my $liniamax;
my $kluczmax;
my $maax=0;
my $mykey;

my $debug=0;
my $space=1;

$debug=1 if ($opt =~ m/v/);
$debug=10 if ($opt =~ m/vv/);
$space=0 if ($opt =~ m/s/);


while(<>)
{
	chomp;
	my @tab;
	my $linia=$_;
	for(my $l=0;$l<256; $l++) {$tab[$l]=0};
	my @cc = (m/(..)/g);
	foreach my $a (@cc)
	{
		my $i=hex($a)."\n";
		$tab[$i]++;
	}
	my %wagi;
	for(my $key=0;$key<256;$key++)
	{
#		my $etaoin="";
#		for(my $l=0;$l<256; $l++) {
#			if ($tab[$l]>0) {
#				my $znak=chr($l^$key);
#				#print $znak.": ".$tab[$l],"\n" ;
#				$etaoin .= $znak if ($l>31);
#			}
#		}
#		if(Etaoin($etaoin)>2)
		{
			my $ss= XorString($key,hex2bin($linia));
			$wagi{$key}=Etaoin($ss);
#			if($wagi{$key}>50){
#				print $key.': '.$etaoin." ";
#				print $ss.' '.$linia.' '.Etaoin($ss)."\n";
#			}
		}
	}
	$maax=0;
	#my $mykey;
	my $prevkey;
	for(my $key=0;$key<256;$key++)
	{
		if ($wagi{$key}>$maax){
			$maax=$wagi{$key};
			$prevkey=$mykey;
			$mykey=$key;
		}
	}
	if($debug){
		print "\nklucz: ".$mykey. ' waga: '.$wagi{$mykey}.' '.XorString($mykey,hex2bin($linia))."\nInne klucze:\n"	;
		my @keys = sort { $wagi{$b} <=> $wagi{$a} } keys(%wagi);
		my @vals = @wagi{@keys};
		for(my $i=1;$i<3;$i++){
			print "klucz: ".$keys[$i]. ' waga: '.$vals[$i].' '.XorString($keys[$i],hex2bin($linia))."\n"	;
		}
	}
	if($maax>$wagamax){
		$wagamax=$maax;
		$liniamax=$linia;
		$kluczmax=$mykey;
	}
}

print "\nklucz: ".$kluczmax. ": $liniamax ".XorString($kluczmax,hex2bin($liniamax))."\n"	;


sub Etaoin
{
	my $string=shift;
	my @tab;
	$string=lc($string);
	my $ee='etaoinshrdlu';
	$ee = ' '.$ee if($space);
	my $m=0;
	my $i=length($ee);
	foreach my $e (split(//,$ee)){
		my $count = () = $string =~ /$e/g;
		$m+=($i*$count);
		
		$i--;
	}	
	return $m;
}

sub hex2bin
{
	my $h= shift;
	my @cc = ($h =~ m/(..)/g);
	my $b;
	foreach my $a (@cc)
	{
		$b .= chr(hex($a));
		#print chr($a);
	}
	return $b;
	
}

#xor(klucz_binarny_bajt, string)
sub XorString
{
	my $k = shift;
	my $b = shift;
	my $r = '';
	foreach my $B (split(//,$b)){
		$r .= chr($k^ord($B));
	}
	return $r;
}		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		

