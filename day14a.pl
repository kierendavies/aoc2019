use strict;
use warnings;

use List::Util qw(min);
use POSIX;

my $reactions = {};

for my $line (<>) {
    chomp $line;
    my ($in, $outQty, $outChem) = ($line =~ /(.*) => (\d+) ([A-Z]+)/);
    $reactions->{$outChem} = {
        in => { map { reverse split(/ /, $_) } split(/, /, $in) },
        out => $outQty,
    };
}

my $need = { map { $_ => 0 } keys %$reactions };
my $surplus = { map { $_ => 0 } keys %$reactions };

$need->{'FUEL'} = 1;
$need->{'ORE'} = 0;
$surplus->{'ORE'} = 0;

while (my @needChems = grep { $_ ne 'ORE' && $need->{$_} > 0 } keys %$need) {
    my $outChem = $needChems[0];
    my $scale = ceil($need->{$outChem} / $reactions->{$outChem}{out});

    for my $inChem (keys %{$reactions->{$outChem}{in}}) {
        my $inQty = $reactions->{$outChem}{in}{$inChem} * $scale;
        my $useSurplus = min($inQty, $surplus->{$inChem});
        $inQty -= $useSurplus;
        $surplus->{$inChem} -= $useSurplus;
        $need->{$inChem} += $inQty;
    }

    $surplus->{$outChem} += $reactions->{$outChem}{out} * $scale - $need->{$outChem};
    $need->{$outChem} = 0;
}

print $need->{'ORE'}, "\n";
