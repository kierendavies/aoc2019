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

sub ore_for_fuel {
    my ($needFuel) = @_;

    my $need = { map { $_ => 0 } keys %$reactions };
    my $surplus = { map { $_ => 0 } keys %$reactions };

    $need->{'FUEL'} = $needFuel;
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

    return $need->{'ORE'};
}

my $max_ore = 1_000_000_000_000;

my $low = 0;
my $high = 1;

while (ore_for_fuel($high) <= $max_ore) {
    $high *= 2;
}

while ($high - $low > 1) {
    my $mid = int(($low + $high) / 2);
    if (ore_for_fuel($mid) <= $max_ore) {
        $low = $mid;
    } else {
        $high = $mid;
    }
}

print $low, "\n";
