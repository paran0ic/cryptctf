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

my $plain= <<ENDS;
SSBoYXZlIG1ldCB0aGVtIGF0IGNsb3NlIG9mIGRheQ==
SSBoYXZlIG1ldCB0aGVtIGF0IGNsb3NlIG9mIGRheQ==
Q29taW5nIHdpdGggdml2aWQgZmFjZXM=
RnJvbSBjb3VudGVyIG9yIGRlc2sgYW1vbmcgZ3JleQ==
RWlnaHRlZW50aC1jZW50dXJ5IGhvdXNlcy4=
SSBoYXZlIHBhc3NlZCB3aXRoIGEgbm9kIG9mIHRoZSBoZWFk
T3IgcG9saXRlIG1lYW5pbmdsZXNzIHdvcmRzLA==
T3IgaGF2ZSBsaW5nZXJlZCBhd2hpbGUgYW5kIHNhaWQ=
UG9saXRlIG1lYW5pbmdsZXNzIHdvcmRzLA==
QW5kIHRob3VnaHQgYmVmb3JlIEkgaGFkIGRvbmU=
T2YgYSBtb2NraW5nIHRhbGUgb3IgYSBnaWJl
VG8gcGxlYXNlIGEgY29tcGFuaW9u
QXJvdW5kIHRoZSBmaXJlIGF0IHRoZSBjbHViLA==
QmVpbmcgY2VydGFpbiB0aGF0IHRoZXkgYW5kIEk=
QnV0IGxpdmVkIHdoZXJlIG1vdGxleSBpcyB3b3JuOg==
QWxsIGNoYW5nZWQsIGNoYW5nZWQgdXR0ZXJseTo=
QSB0ZXJyaWJsZSBiZWF1dHkgaXMgYm9ybi4=
VGhhdCB3b21hbidzIGRheXMgd2VyZSBzcGVudA==
SW4gaWdub3JhbnQgZ29vZCB3aWxsLA==
SGVyIG5pZ2h0cyBpbiBhcmd1bWVudA==
VW50aWwgaGVyIHZvaWNlIGdyZXcgc2hyaWxsLg==
V2hhdCB2b2ljZSBtb3JlIHN3ZWV0IHRoYW4gaGVycw==
V2hlbiB5b3VuZyBhbmQgYmVhdXRpZnVsLA==
U2hlIHJvZGUgdG8gaGFycmllcnM/
VGhpcyBtYW4gaGFkIGtlcHQgYSBzY2hvb2w=
QW5kIHJvZGUgb3VyIHdpbmdlZCBob3JzZS4=
VGhpcyBvdGhlciBoaXMgaGVscGVyIGFuZCBmcmllbmQ=
V2FzIGNvbWluZyBpbnRvIGhpcyBmb3JjZTs=
SGUgbWlnaHQgaGF2ZSB3b24gZmFtZSBpbiB0aGUgZW5kLA==
U28gc2Vuc2l0aXZlIGhpcyBuYXR1cmUgc2VlbWVkLA==
U28gZGFyaW5nIGFuZCBzd2VldCBoaXMgdGhvdWdodC4=
VGhpcyBvdGhlciBtYW4gSSBoYWQgZHJlYW1lZA==
QSBkcnVua2VuLCB2YWluLWdsb3Jpb3VzIGxvdXQu
SGUgaGFkIGRvbmUgbW9zdCBiaXR0ZXIgd3Jvbmc=
VG8gc29tZSB3aG8gYXJlIG5lYXIgbXkgaGVhcnQs
WWV0IEkgbnVtYmVyIGhpbSBpbiB0aGUgc29uZzs=
SGUsIHRvbywgaGFzIHJlc2lnbmVkIGhpcyBwYXJ0
SW4gdGhlIGNhc3VhbCBjb21lZHk7
SGUsIHRvbywgaGFzIGJlZW4gY2hhbmdlZCBpbiBoaXMgdHVybiw=
VHJhbnNmb3JtZWQgdXR0ZXJseTo=
QSB0ZXJyaWJsZSBiZWF1dHkgaXMgYm9ybi4=
ENDS

my @plain=split(/\n/,$plain);

my @ciph;
my $i=0;

foreach (@plain){
	$ciph[$i++] = (cryptctr(decode_base64($_),$key,$nonce));
}


#lamanie - test 'The '

my $guess="th";
my $testkey = '';chr(0) x 64;
my $lines= scalar @ciph;
my $lines2= scalar @ciph;

for(my $pos=0;$pos<64;$pos+=1)#length($guess)/2)
{ 
	my $mm=0;
	$lines=$lines2-1;
	$lines2=scalar @ciph;
	foreach (@ciph){
		if(length($_)>$pos+length($guess)){
			my $subkey = substr($_ ,$pos,length($guess)) ^ $guess;
			my $m=0;
			foreach my $c (@ciph){
				if(length($c)>$pos+length($guess)){
					$m++ if(testSubkey($c, $subkey, $pos, $guess));
				}
			}
			if(($m>$mm) && ($m>$lines/4)){
				#print "$m: $subkey ",toHex($subkey),"\n";
				#print ' ' x $pos, substr($ciph[3] ,$pos,length($guess)) ^ $subkey;
				if($m>int($lines*3/4)){
					$testkey = substr($testkey,0,$pos).$subkey;
				}else{
					$testkey = substr($testkey,0,$pos+1).substr($subkey,1,length($guess)-1);
				}
				$mm = $m;
			}
		}else{
			$lines2--;
		}
	}
	if($mm>1){
		print substr(($ciph[3])^$testkey,0,$pos+length($guess)),"\n";
	}
}
foreach (@ciph){
	print substr($_^$testkey,0,length($_)),"\n";
}
print cryptctr($ciph[23], $key, $nonce);
print "\n";


sub testSubkey
{
	my ($ciph, $subkey,$pos,$guess)=@_;
	my $len = length($guess);
	my $c=substr($ciph,$pos,$len)^$subkey;		
	#$c = lc($c);
	#lc($guess);
	#print $c;
	if($c =~ m/[a-zA-Z ,.\-\?]{$len}/){
	#if($c eq $guess){
		#print "$c\n";
		return 1; 
	}
	return 0;
}
