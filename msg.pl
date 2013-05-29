#!/usr/bin/local/perl                                                                                                                                                                                                                 

use Net::Twitter;
use Scalar::Util 'blessed';

use strict;

# some variables                                                                                                                                                                                                                      

my ($txt, @sentences, @beginnings, @arr, %db, $print_msg, $max, $src, $stemlength, $stem, @lens);

@lens = (1, 1, 1, 1, 2, 3, 4, 8);

$max = 80 + rand(50);
#$stemlength = $lens[rand($#lens)];                                                                                                                                                                                                   
$stemlength = 1;


#$max = 140;                                                                                                                                                                                                                          

$src = '/home/gameolog/pg/pelafina/whalestoe.txt';

open READ, $src or die "Could not find source file!";;

while (<READ>){
      chomp;
      $_ =~ s/\n|\r|\n\r//ig;
      $txt .= $_;
}
close READ;

@arr = split(/\s+/, $txt);

for (my $i = 0; $i < $#arr; $i++){
    $stem = '';
    unless (defined $db{$arr[$i]}){
        $db{$arr[$i]} = [];
    }

    for (my $l = 1; $l <= $stemlength; $l++){
        $stem .= $arr[$i + $l] . " ";
    }

    push (@{$db{$arr[$i]}}, $stem);




}


map { push(@beginnings, $_) if (/^[A-Z]/) } keys %db;

for (my $t = 0; $t < 10; $t++){
      my $sent = $beginnings[rand($#beginnings)] . " ";
      while (length($sent) < 140){
            my @sofar = split(/\s/, $sent);
            my @from = @{$db{$sofar[$#sofar]}};
            my $next = $from[rand($#from)];
            $sent .= "$next ";

            if ($next =~ /(\.|\?|\!)\s*$/){
                  last;
            }
      }
      push (@sentences, $sent);
}

foreach (@sentences){
    if (length($print_msg) + length($_) < $max){
        $print_msg .= $_;
    }

}

$print_msg =~ s/\s\s/ /g;

#print length($print_msg) . "\n $print_msg \n";                                                                                                                                                                                       

#DO A TWEET                                                                                                                                                                                                                           

#twitter config                                                                                                                                                                                                                       
 my $nt = Net::Twitter->new(
      traits   => [qw/API::RESTv1_1/],
     consumer_key => '',
     consumer_secret => '',
     access_token => '',
     access_token_secret => '',

    );

my $result = $nt->update($print_msg);

if ( my $err = $@ ) {
    die $@ unless blessed $err && $err->isa('Net::Twitter::Error');

      warn "HTTP Response Code: ", $err->code, "\n",
           "HTTP Message......: ", $err->message, "\n",
    "Twitter error.....: ", $err->error, "\n";
}


