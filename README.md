# cryptctf

https://cryptopals.com

Set 1
Challenge 6

for ll in `cat 6.txt |./6vigenere.pl v|tail -29`; do echo $ll|./cc.pl;done|strings|grep klucz|cut -d: -f1,2,4

for ii in `cat 6.klucz |cut -d'(' -f2|cut -d')' -f1`; do echo -n $ii;done

cat 6.txt| ./5xorem-go.pl 'Terminator X: Bring the noise' tb
