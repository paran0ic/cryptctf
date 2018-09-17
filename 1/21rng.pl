#!/usr/bin/perl

use strict;
## Object-oriented interface:
use Math::Random::MT;
my $gen = Math::Random::MT->new(123);  # or...
#$seed = $gen->get_seed();             # seed used to generate the random numbers
#$rand = $gen->rand(42);               # random number in the interval [0, 42)
#$dice = int($gen->rand(6)+1);         # random integer between 1 and 6
#$coin = $gen->rand() < 0.5 ?          # flip a coin
#  "heads" : "tails"

my $gg=500;
for(my $i=0;$i<$gg;$i++){
#	print $gen->irand(),"\n";  
}

print "\n\n";


#use bigint;

# Utwórz tablicę 624 elementów do przechowywania stanu generatora
my @MT;
$MT[623]=0;
my $index = 0;


initializeGenerator(123);

for(my $i=0;$i<$gg;$i++){
	print extractNumber(),"\n";
}
 
 
# Inicjuj generator przy użyciu ziarna
sub initializeGenerator{
	my $seed = int(shift);
     $MT[0] = $seed;
     for(my $i=1;$i<624;$i++) { # pętla po każdym elemencie
         $MT[$i] = 0xffffffff & (0x6c078965 * ($MT[$i-1] ^ ($MT[$i-1]>>30)) + $i); # 0x6c078965
     }
 }
 
# Utwórz pseudolosową liczbę na podstawie indeksu,
# wywołaj generateNumbers() aby utworzyć nową tablicę pomocniczą co 624 liczby
sub extractNumber {
     if($index == 0) {
         generateNumbers();
     }
     
     my $y = $MT[$index];
     $y = $y ^ ($y>>11);
     $y = $y ^ (($y<<7) & 0x9d2c5680); # 0x9d2c5680
     $y = $y ^ (($y<<15) & 0xefc60000); # 0xefc60000
     $y = $y ^ ($y>>18);
     
     $index = ($index + 1) % 624;
     return $y;
 }
 
# Generuj tablicę 624 liczb
sub generateNumbers {
     for(my $i=0;$i<624;$i++) {
         my $y = 0x80000000 & ($MT[$i]) + 0x7fffffff & ($MT[($i+1) % 624]);
         $MT[$i] = $MT[($i + 397) % 624] ^ (($y>>1));
         if (($y % 2) == 1) { # y is odd
             $MT[$i] = $MT[$i] ^ (0x9908b0df); # 0x9908b0df
         }
     }
 }
