#!/usr/bin/perl -w

 use utf8;
 no utf8;
use MIME::Base64;
use strict;

my $key=shift;
#"ICE";
my $opt='';
my $textoutput=0;
my $b64input=0;
$opt=shift;
if($opt){
	if($opt =~ m/h/i){
		print "usage: command KEY option\nb - decode base64 t - text out\n";
		exit 0;
	}
	if($opt =~ m/t/i){
		$textoutput=1;
	}
	if($opt =~ m/b/i){
		$b64input=1;
	}

}
print "Key used: \n$key***\n\n";

my @k=split(//,$key);
my $i=0;
my $pos=0;
binmode(STDIN);


my $line = join("",<>);
my $in = $line;

if($b64input){
	$in=decode_base64( $line );
}
utf8::downgrade($in,0);

my @l=split(//,$in);
foreach my $c (@l){
	if($textoutput){
		print chr(ord($k[$i])^ord($c));
	}
	else{
		printf("%02x", ord($k[$i])^ord($c));
		if($pos++>35){
			print "\n" ;
			$pos=0;
		}
	}
	
	$i=0 if(++$i>=length($key));
	
}


print "\n";
