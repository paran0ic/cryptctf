#!/usr/bin/perl -w

#use OpenSSL::Cipher;
use Crypt::Cipher;
#use Crypt::Mode::ECB;
use MIME::Base64;
use strict;
use mycrypto;

my $isECB;
my $key=randomkey();
my $iv=randomkey();
#binmode(STDIN);
#$text=join('',<>);

$key='vP/@{hF"=1i|q4sY';


my $text3 ='Um9sbGluJyBpbiBteSA1LjAKV2l0aCBteSByYWctdG9wIGRvd24gc28gbXkg
aGFpciBjYW4gYmxvdwpUaGUgZ2lybGllcyBvbiBzdGFuZGJ5IHdhdmluZyBq
dXN0IHRvIHNheSBoaQpEaWQgeW91IHN0b3A/IE5vLCBJIGp1c3QgZHJvdmUg
YnkK';
$text3=decode_base64($text3);
my $text1 = 'z' x int rand(1167);

my $firstModBlock=0;
my $posInModBlock=0;

my $blocksize=detectBlockSize();
print "Blocksize detected: $blocksize\n";

if($blocksize==0){
	print "\nCant detect blocksize\n";
	exit 1;
}

;
my $is_ecb = ecb_detect();
print "ECB detected: $is_ecb\n";

if($is_ecb){

	detectPrependLen();
	$|=1; #unbuffered mode output (slow char by char)
	print "Crack ECB oracle...\n\n";

	guessBlockECB($text3,0);
	print "\nDone.\n";
}

exit 0;


#print decryptecb($ciph,$key);
exit 0;

sub detectPrependLen
{
	my $p1=oracle('');
	my $p2=oracle('a');
	#detect first block modified
	my $i=0;
	for($i=0;$i<length($p1);$i++){
		if(getBlock($p1,$i) ne getBlock($p2,$i)){
			last;
		}
	}
	$firstModBlock=$i;
	#detect position in modifed block
	for($i=0;$i<$blocksize+1;$i++){
		$p2=oracle('a' x $i);
		$p1=oracle('b' x $i);
		if(getBlock($p1,$firstModBlock+1) ne getBlock($p2,$firstModBlock+1)){
			last;
		}
		
	}
	$posInModBlock=$blocksize-$i+1;
	print "Prepend blocks/chars: $firstModBlock  $posInModBlock\n";
}

sub getBlock
{
	my ($t,$n)=@_;
	return substr($t,$n*$blocksize,$blocksize);
}
sub detectBlockSize
{
	my $x=length oracle('');
	for(my $l=1;$l<256;$l++){
		my $y = length oracle('a' x $l);
		return ($y-$x) if($y>$x);
	}
	return 0;
}

sub guessBlockECB
{
	my ($text,$n)=@_;
	my $znak='';
	my $guessed='';

	for(my $j=0;$j<length($text);$j++){
		$znak = guessByteECB($text,$guessed);
		$guessed .=$znak;
	}
	return $guessed;
}
sub guessByteECB
{
	my ($text,$known)=@_;
	my $knownLen=length($known);
	my $knownBlocks=int ($knownLen / $blocksize);
	my $padlen= ($blocksize-1-($knownLen % $blocksize)-$posInModBlock) ;
	if($padlen<=0 ){
		$padlen = $blocksize+$padlen;
		$knownBlocks++;
	}
	my $ciph=oracle('A' x $padlen);
	my $znak;
	my $ciphBlock=substr($ciph,$blocksize*($knownBlocks+$firstModBlock),$blocksize);
	
	for(my $i=0;$i<256;$i++){
		if(substr(oracle( 'A' x $padlen .$known.chr($i)),$blocksize*($knownBlocks+$firstModBlock),$blocksize) eq $ciphBlock){
			$znak=chr($i);
			print $znak;
			last;
		}
	}
	return $znak;
}

sub oracle
{
	my $t=shift;
#	print $t."\n";
	return encryptecb($text1.$t.$text3,$key);
}



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
	my @bins=split(//,oracle('').oracle('a' x $blocksize));
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
