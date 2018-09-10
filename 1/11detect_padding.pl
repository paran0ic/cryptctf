#!/usr/bin/perl -w

#use OpenSSL::Cipher;
use Crypt::Cipher;
#use Crypt::Mode::ECB;
use strict;
use mycrypto;

my $isECB;
my $key=randomkey();
my $iv=randomkey();
my $text='MEANINGLESS JIBBER JABBER';
binmode(STDIN);
$text=join('',<>);


#print encryption_oracle($text);
#exit 0;

for(my $z=6550;$z<65536;$z++){
	$key=randomkey();
	$iv=randomkey();


	length($key) or die "usage: toolname key [opts]";
	#print $key;

	#print XorStrings($key,XorStrings($key,'ala ma kota Lota'));
	#exit 0;
	#my $iv="\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0";

	my $detECB =  ecb_detect(encryption_oracle($text));

	print 'ECB' if($isECB);
	print 'CBC' if($isECB==0);
	print " $isECB $detECB\n";
	if($isECB != $detECB){
		print "\nDetection error for key: $key iv: $iv\n\n";
		exit 1;
	}
}
exit 0;
#my $p= $text; #mycrypto::decryptcbc($text,$key,$iv);
#my $c= mycrypto::encryptcbc($p,$key,$iv);
#my $p1= mycrypto::decryptcbc($c,$key,$iv);

#print '-' x 20 ."\n$p\n";
#print '-' x 20 ; 
#print "\n$p1\n";


sub encryption_oracle{
	my $text=shift;
	$text=padding(randomkey(int rand(5)+5).$text.randomkey(int rand(5)+5));
#	print "\n$text\n";
	if(int rand(2)){
		$isECB=1;
		return encryptecb($text,$key).1;
	}
	else{
		$isECB=0;
		return encryptcbc($text,$key,$iv).0;
	}
	
}

sub ecb_detect
{
	my $ciph=shift;
	my @bins=split(//,$ciph);
	my $blocksize = 16;
	my $j=-1;
	my @blocks; 
	for(my $i=0;$i<(scalar @bins);$i++){
		if($i%$blocksize==0) {$j++;}#print "\n";}
		$blocks[$j] .= sprintf("%0X",ord($bins[$i]));
		#printf("%02X",ord($bins[$i]));
	}
	#print scalar @blocks.' ';
	for(my $x=0;$x<(scalar @blocks)/2;$x++){
		for(my $y=0;$y<(scalar @blocks);$y++){
			if($x != $y){
				if($blocks[$x] eq $blocks[$y]){
#					print $blocks[$x]. ' ' .  $blocks[$y];
					return 1;
				}
			}				
		}
	}
	return 0;
	
}
