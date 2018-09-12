#!/usr/bin/perl -w

use strict;
use mycrypto;

my @t=('ala'.chr(13) x 13, '1234567890ABCDEF'.chr(15) . chr(16) x 15, '1234567890ABCDE'.chr(1));

foreach (@t){
    print padding_valid($_)."\n";
}


