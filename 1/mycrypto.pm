package mycrypto;

use Crypt::Cipher;
use strict "vars";
use vars qw(@ISA @EXPORT);
use Exporter;
#require Exporter;
@ISA = qw(Exporter);

@EXPORT = qw/decryptcbc encryptcbc decryptecb encryptecb padding XorStrings randomkey toHex printRule padding_valid/;

sub decryptcbc
{
	my ($ciph,$key,$iv) = @_;
	my @bins=split(//,$ciph);
	my $c = Crypt::Cipher->new('AES', $key);
	my $blocksize  = $c->blocksize;
	my $j=-1;
	my @blocks; #= ($text =~ m/(.{16})/gm);
	for(my $i=0;$i<(scalar @bins);$i++){
		if($i%$blocksize==0) {$j++;}
		$blocks[$j] .= $bins[$i];
	}
	my $ciphertext  = $iv;
	my $plaintext='';
	my $lastplain='';
	foreach my $b (@blocks){
		$plaintext  .= $lastplain; 
		$lastplain = $c->decrypt($b)^$ciphertext;         #decrypt 1 block
	#	$lastplain = XorStrings($c->decrypt($b),$ciphertext);         #decrypt 1 block
	#	my $ciphertext = $c->encrypt($_); #encrypt 1 block
		$ciphertext=$b;
	
	}
	if(padding_valid($lastplain)==0){
	    return "paddingerror";
	}
	my @last= split(//,$lastplain);
	my $pad=ord $last[$blocksize-1];
	for(my $i=$blocksize-1;$i>1;$i--){
		if($pad != ord $last[$i]){
			if($pad != $blocksize-$i-1){
				print "paddingerror! ";
			}else{
				$i=0;
				last;
			}
		}
		$pad= ord($last[$i]);
	
	}
	for(my $i=0;$i<$blocksize-$pad;$i++){
		$plaintext .= $last[$i];
	}
	return $plaintext;
}

sub decryptecb
{
	my ($ciph,$key,$iv) = @_;
	my @bins=split(//,$ciph);
	my $c = Crypt::Cipher->new('AES', $key);
	my $blocksize  = $c->blocksize;
	my $j=-1;
	my @blocks; #= ($text =~ m/(.{16})/gm);
	for(my $i=0;$i<(scalar @bins);$i++){
		if($i%$blocksize==0) {$j++;}
		$blocks[$j] .= $bins[$i];
	}
	my $ciphertext  = $iv;
	my $plaintext='';
	my $lastplain='';
	foreach my $b (@blocks){
		$plaintext  .= $lastplain; 
		$lastplain = $c->decrypt($b);         #decrypt 1 block
	#	$lastplain = XorStrings($c->decrypt($b),$ciphertext);         #decrypt 1 block
	#	my $ciphertext = $c->encrypt($_); #encrypt 1 block
	
	}
	my @last= split(//,$lastplain);
	my $pad=ord $last[$blocksize-1];
	if($pad<17){
		for(my $i=$blocksize-1;$i>1;$i--){
			if($pad != ord $last[$i]){
				if($pad != $blocksize-$i-1){
					print "padding error! ";
				}else{
					$i=0;
					last;
				}
			}
			$pad= ord($last[$i]);
	
		}
		for(my $i=0;$i<$blocksize-$pad;$i++){
			$plaintext .= $last[$i];
		}
	}
	return $plaintext;
}
sub encryptcbc
{
	my ($ciph,$key,$iv) = @_;
	my $c = Crypt::Cipher->new('AES', $key);
	my $blocksize  = $c->blocksize;
	if((length($key) != $blocksize) || (length($iv) != $blocksize)){
	    die "bad KEY or IV\n"; 
	}
	my @bins=split(//,$ciph);
	my $j=-1;
	my @blocks; #= ($text =~ m/(.{16})/gm);
	for(my $i=0;$i<(scalar @bins);$i++){
		if($i%$blocksize==0) {$j++;}
		$blocks[$j] .= $bins[$i];
	}
	my $padd=$blocksize-length($blocks[-1]);
	#print "$padd \n";
	if($padd){
		$blocks[-1] .= chr($padd) x $padd;
	}else{
	    $blocks[scalar @blocks]=chr($blocksize) x $blocksize;
	}
	my $ciphertext ='';
	my $lastciph=$iv;
	foreach my $b (@blocks){
		$lastciph = $c->encrypt(XorStrings($b,$lastciph)); #encrypt 1 block
		$ciphertext .= $lastciph; 
	}
	return $ciphertext;
}

sub encryptecb
{
	my ($ciph,$key,$iv) = @_;
	my $c = Crypt::Cipher->new('AES', $key);
	my $blocksize  = $c->blocksize;
	my @bins=split(//,$ciph);
	my $j=-1;
	my @blocks; #= ($text =~ m/(.{16})/gm);
	for(my $i=0;$i<(scalar @bins);$i++){
		if($i%$blocksize==0) {$j++;}
		$blocks[$j] .= $bins[$i];
	}
	my $padd=$blocksize-length($blocks[-1]);
	#print "$padd\n";
	if($padd>0){
		$blocks[-1] .= chr($padd) x $padd;
	}else{
	    $blocks[scalar @blocks]=chr($blocksize) x $blocksize;
	}
	my $ciphertext ='';
	my $lastciph='';
	foreach my $b (@blocks){
	#print "$b";
		$lastciph = $c->encrypt($b); #encrypt 1 block
		$ciphertext .= $lastciph; 
	}
	return $ciphertext;
}

sub padding{
	my ($text, $blocksize) = @_;
	length($blocksize) or $blocksize=16;
	my $padd=length($text)%$blocksize;
	#print "$padd \n";
	if($padd){
		$text .= chr($padd) x $padd;
	}
	return $text;
}

sub XorStrings
{
	my $k = shift;
	my $b = shift;
	my $r = $k^$b;
	return $r;
	my @kk = split(//,$k);
	my @bb =split(//,$b);
	for(my $i=0;$i<length($k);$i++){
		$r .= chr(ord($kk[$i])^ord($bb[$i]));
	}
	return $r;
}

sub randomkey
{
	my $len=shift;
	length($len) or $len=16;
	my $key='';

	for(my $i=0;$i<$len;$i++){
		$key.=chr(int(rand(127-32)+32));
	}
	return $key;
}
sub toHex
{
	my $r='';
	my $i=0;
	foreach (split(//,shift)){
		$r.=sprintf("%.02X",ord($_));
		$r .="\n" if(++$i%16==0);
	}
	return $r;
}

sub printRule
{
	print "0123456789ABCDEF";
}
sub padding_valid
{
	my ($text,$blocksize) = @_;
	my @bins=split(//,$text);
	$blocksize  or  $blocksize=16;
	my $j=-1;
	my @blocks; #= ($text =~ m/(.{16})/gm);
	for(my $i=0;$i<(scalar @bins);$i++){
		if($i%$blocksize==0) {$j++;}
		$blocks[$j] .= $bins[$i];
	}
	my @last= split(//,$blocks[-1]);
	if(scalar @last != $blocksize){
        #print "Padding error 1: last block len<>16! " ;
        return 0;
	}
	my $pad=ord $last[$blocksize-1];
    if($pad<1 || $pad>$blocksize){
        #print "Padding error 2: last byte > $blocksize! " ;
        return 0;
    }
    
    
    if(substr($blocks[-1],$blocksize-$pad, $pad) ne chr($pad) x $pad){
		#print "padding error 3: mismatch! ";
		return 0;
    }
    
	for(my $i=$blocksize-$pad;$i<$blocksize;$i++){
		if($pad != ord $last[$i]){
			if($pad != $blocksize-$i-1){
#				print "padding error 3: mismatch! ";
#				return 0;
			}
		}
	}
	return 1 ;
}

1;		

