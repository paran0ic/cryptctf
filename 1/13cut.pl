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
#binmode(STDIN);
#$text=join('',<>);

$key='vP/@{hF"=1i|q4sY';


my $blocksize=detectBlockSize();

if($blocksize==0){
	print "\nCant detect blocksize\n";
	exit 1;
}

print "Blocksize detected: $blocksize\n";

my $is_ecb = ecb_detect();
print "ECB detected: $is_ecb\n";


my $toattacker = enc_profile("foo\@bar.com");

print toHex($toattacker);

my $fromattacker = $toattacker;
my $crackedprofile=dec_profile($fromattacker);

print "$crackedprofile\n";
#printRule;printRule;
print "\n\n";
#my %p=parse($crackedprofile);
#print Dumper \%p;

#
#	email=foo@bar.com&id=10&role=user
#	0123456789ABCDEF0123456789ABCDEF
#
#	need longer email ended 'admin' with padding
#	email=foo@bar.coadmin&id=10&role=user
#	0123456789ABCDEF0123456789ABCDEF
#	      foo@bar.coadmin\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b

my $admin1 = enc_profile("foo\@bar.coadmin". "\x0b" x 11);
print toHex($admin1);
print dec_profile($admin1);
print "\n";

#	need longer email to set name of role on beginning of new block
#	email=foo@bar.colong&id=10&role=user
#	0123456789ABCDEF0123456789ABCDEF
#	      foo@bar.colong

my $admin2 = enc_profile("foo\@bar.colong");
print toHex($admin2);
print dec_profile($admin2);

#	now I need:
#	1 and 2 block of admin2
#	and 2 block od admin1

print "\n\n";

$fromattacker=substr($admin2,0,$blocksize*2).substr($admin1,$blocksize,$blocksize);

print toHex($fromattacker);

$crackedprofile=dec_profile($fromattacker);

print "$crackedprofile";
print "\n\n";
my %p=parse($crackedprofile);
print Dumper \%p;
exit 0;
sub oracle
{
	return enc_profile(shift);
}
sub enc_profile
{
	my $email=shift;
	return encryptecb(profile_for($email),$key);
}

sub dec_profile
{
	return (decryptecb(shift,$key));
}

sub parse
{
	my @paires=split(/\&/,shift);
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

sub profile_for
{
	my $email=shift;
	$email =~ s/(\=|\&)//gm;
	#$email=$1;
	my $id=10;
	my $role='user';
	return "email=$email&id=$id&role=$role";
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

