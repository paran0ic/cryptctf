#!/usr/bin/perl -w

#use OpenSSL::Cipher;
use Crypt::Cipher;
use Crypt::Mode::ECB;
use strict;


my $key=shift;
length($key) or die "usage: toolname key [opts]";



my $ciphertext=join('',<>);
my $ecb = Crypt::Mode::ECB->new('AES');
my $plaintext = $ecb->decrypt($ciphertext, $key);

print $plaintext;
