#!/usr/bin/perl -w

#use OpenSSL::Cipher;
#use Crypt::Cipher;
#use Crypt::Mode::ECB;
use strict;
require "mycrypto.pm";

my $key=shift;
length($key) or die "usage: toolname key [opts]";

#print XorStrings($key,XorStrings($key,'ala ma kota Lota'));
#exit 0;
my $iv="\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0";

binmode(STDIN);
my $text=join('',<>);

my $p= mycrypto::decryptcbc($text,$key,$iv);
my $c= mycrypto::encryptcbc($p,$key,$iv);
my $p1= mycrypto::decryptcbc($c,$key,$iv);

#print '-' x 20 ."\n$p\n";
#print '-' x 20 ; 
print "\n$p1\n";

#xor(klucz_string, string)


