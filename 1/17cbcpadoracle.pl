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

$key='vP/@{hF"=1i|q4sY';
$iv= 'dfsdfsd|q68(4ml8';

my @text = split /\n/, <<HERE1;
MDAwMDAwTm93IHRoYXQgdGhlIHBhcnR5IGlzIGp1bXBpbmc=
MDAwMDAxV2l0aCB0aGUgYmFzcyBraWNrZWQgaW4gYW5kIHRoZSBWZWdhJ3MgYXJlIHB1bXBpbic=
MDAwMDAyUXVpY2sgdG8gdGhlIHBvaW50LCB0byB0aGUgcG9pbnQsIG5vIGZha2luZw==
MDAwMDAzQ29va2luZyBNQydzIGxpa2UgYSBwb3VuZCBvZiBiYWNvbg==
MDAwMDA0QnVybmluZyAnZW0sIGlmIHlvdSBhaW4ndCBxdWljayBhbmQgbmltYmxl
MDAwMDA1SSBnbyBjcmF6eSB3aGVuIEkgaGVhciBhIGN5bWJhbA==
MDAwMDA2QW5kIGEgaGlnaCBoYXQgd2l0aCBhIHNvdXBlZCB1cCB0ZW1wbw==
MDAwMDA3SSdtIG9uIGEgcm9sbCwgaXQncyB0aW1lIHRvIGdvIHNvbG8=
MDAwMDA4b2xsaW4nIGluIG15IGZpdmUgcG9pbnQgb2g=
MDAwMDA5aXRoIG15IHJhZy10b3AgZG93biBzbyBteSBoYWlyIGNhbiBibG93
HERE1


my $t = $text[int rand(scalar @text)];

my $ciph = func1($t);
print "iv:\n$iv\nciph:\n".toHex($ciph);

print '-' x 32; print "\n"; 

print "Padding valid: ". func2($ciph)."\n";



my @blocks = ciph2block($ciph);
my @Cp=split(//,randomkey());
my $ciph2;
my $plainblock='';

print '-' x 32; print "\n"; 

my $N=1;

my @Co=split(//,$blocks[($#blocks - $N)]);

for(my $j=1;$j<$blocksize;$j++){
    my $i=$blocksize-$j; #pozycja do testowania
    my $z=0; #pasujacy znak
    for($z=0;$z<256;$z++){
        $Cp[$i]=chr($z);
        $ciph2=join('',@blocks[0..($#blocks - $N)],join('',@Cp),$blocks[-1]);
        if(oracle($ciph2)){
            print $z;
            last;
        }
    }
    my $D=chr($j)^chr($z);
    my $P=$D^$Co[$i];
    printf("%d %d z:%.2X d:%.2X p:%.2X Co:%.2X\n",$i,$j,$z,ord($D),ord($P),ord($Co[$i]));
    print toHex(join('',@Cp));
    $Cp[$i]=$D^chr($j+1);
    for(my $c=1;$c<$j;$c++){
        $Cp[$i+$c]=  $Cp[$i+$c]^chr($j)^chr($j+1)
    } 
    $plainblock.=$P if(ord($P)>$blocksize);
}
print '-' x 32; print "\n"; 

print toHex($ciph2);

print "Plain last block: ".reverse($plainblock)."\n";
sub oracle
{
    return func2(shift);
}

sub func1
{
    return encryptcbc(decode_base64(shift),$key,$iv);
}

sub func2
{
    if(decryptcbc(shift,$key,$iv) eq "paddingerror"){
        return 0;
    }else{
        return 1
    }
}
sub ciph2block
{
    my ($ciph, $n,$knowntext,$newtext) = @_;
	my @bins=split(//,$ciph);
	my $j=-1;
	my @block; #= ($text =~ m/(.{16})/gm);
	for(my $i=0;$i<(scalar @bins);$i++){
		if($i%$blocksize==0) {$j++;}
		$block[$j] .= $bins[$i];
	}
	return @block;
}

