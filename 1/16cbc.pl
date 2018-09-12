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
my $iv=randomkey();
my $blocksize=16;
#binmode(STDIN);
#$text=join('',<>);

#$key='vP/@{hF"=1i|q4sY';
#$iv= 'dfsdfsd|q68(4ml8';

    
my $fraza =shift;
$fraza or $fraza = ";admin=true";
my $known=         ".aaaaaaaaaa";


my $ciph=oracle($known);

printRule; 
print "\n";
print ('-' x 32);
print "\n\n";

print toHex($ciph);

#                       ";admin=true";
$ciph=mod_block($ciph,1,$known,$fraza);

print ('-' x 32);
print "\n\n";

print toHex($ciph);

dec_oracle($ciph);


sub mod_block
{
    my ($ciph, $n,$knowntext,$newtext) = @_;
	my @bins=split(//,$ciph);
	my $j=-1;
	my @block; #= ($text =~ m/(.{16})/gm);
	for(my $i=0;$i<(scalar @bins);$i++){
		if($i%$blocksize==0) {$j++;}
		$block[$j] .= $bins[$i];
	}
	$block[$n]=($block[$n]^$knowntext)^$newtext;
	return join('',@block);
}

sub dec_oracle
{
    my %p=parse(decryptcbc(shift,$key,$iv));
    print Dumper(\%p); 
    return %p;
}

sub oracle
{
	my $t=shift;
	my $pre="comment1=cooking%20MCs;userdata=";
	my $post=";comment2=%20like%20a%20pound%20of%20bacon";
	$t =~ s/\;/./gm;
	$t =~ s/\=/./gm;
	$t= $pre.$t.$post;
	print $t."\n";
	return encryptcbc($t,$key,$iv);
}

sub parse
{

    my @paires=split(/\;/,shift);
    print "@paires\n";
	my %p;
	foreach (@paires){
		chomp;
		if (m/(\S+)=(\S+)/){
			$p{$1}=$2;
#			print "$1 -> $2\n";
		}
	}
	return %p
}


