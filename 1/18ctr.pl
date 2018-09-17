#!/usr/bin/perl -w

#use OpenSSL::Cipher;
use Crypt::Cipher;
#use Crypt::Mode::ECB;
use MIME::Base64;
use strict;
use mycrypto;
use Data::Dumper;

my $isECB;
my $key=randomkey();
my $nonce=randomkey();
my $blocksize=16;
#binmode(STDIN);
#$text=join('',<>);

$key='YELLOW SUBMARINE';
$nonce=pack("Q>",0);

my $ciph='L77na/nrFsKvynd6HzOoG7GHTLXsTVu9qvY/2syLXzhPweyyMTJULu/6/kXX0KSvoOLSFQ==';
$ciph='SSBoYXZlIG1ldCB0aGVtIGF0IGNsb3NlIG9mIGRheQ==';

print (decryptctr(decode_base64($ciph),$key,$nonce));

print "\n";

sub decryptctr
{
	my ($text,$key,$nonce) = @_;
	my $out='';
	my $ctr=0;
	my $c = Crypt::Cipher->new('AES', $key);
	my $blocksize  = $c->blocksize;
	if((length($key) != $blocksize) || (length($nonce) != $blocksize/2)){
	    die "bad KEY or IV\n"; 
	}
	my @block = split2block($text,$blocksize);
	foreach (@block){
		#print $_,"\n";
		my $binctr=pack("Q<", $ctr);
		$ctr++;
		my $keystream=substr($c->encrypt($nonce.$binctr),0,length($_)); #substr bo obciecie ostatniego bloku
		$out .=$keystream^$_;
	}
	return $out; 
}

sub split2block
{
    my ($ciph, $n) = @_;
    my $cliphlen=length($ciph);
	my @bins=split(//,$ciph);
	my $j=-1;
	my @block; #= ($text =~ m/(.{16})/gm);
	for(my $i=0;$i<(scalar @bins);$i++){
		if($i%$n==0) {$j++;}
		$block[$j] .= $bins[$i];
	}
	return @block;
}

