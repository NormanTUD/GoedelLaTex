#!/usr/bin/perl

use strict;
use warnings;
use ntheory qw/is_prime factor nth_prime/;
use List::MoreUtils qw(uniq);
use Term::ANSIColor;
use Data::Dumper;

my $test = 1;
if($test) {
	#mytest("test mytest('...', 1, 1)", 1, 1);
	#mytest("test mytest('...', 1, 0)", 1, 0);
	mytest("x_teilbar_y(10, 2)", x_teilbar_y(10, 2), 1);
	mytest("x_teilbar_y(10, 2)", x_teilbar_y(9, 2), 0);
	mytest("prim(11)", prim(11), 1);
	mytest("prim(10)", prim(10), 0);
	mytest("n_pr_x(0, 1)", n_pr_x(0, 1), 0);
	mytest("n_pr_x(1, 100)", n_pr_x(1, 100), 2);
	mytest("n_pr_x(3, 100)", n_pr_x(3, 100), 5);
	mytest("n_pr_x(3, 105)", n_pr_x(3, 105), 7);
	mytest("faculty(1)", faculty(1), 1);
	mytest("faculty(3)", faculty(3), 6);
	mytest("faculty(4)", faculty(4), 24);
	mytest("pr(1)", pr(1), 2);
	mytest("pr(2)", pr(2), 3);
	mytest("pr(4)", pr(4), 7);
	mytest("n_gl_x(2, 453)", n_gl_x(2, 453), 1);
	#concat
	mytest("r(12)", r(12), 2**12); 

	mytest("l(12)", l(232132), 4); 
}

#9
sub r {
	my $x = shift;
	return 2 ** $x;
}

#8
sub concat {
	...
}

#7

sub l {
	my $x = shift;

	for (my $y = 1; $y <= $x; $y++) {
		if(n_pr_x($y, $x) > 0) {
			if(n_pr_x($y + 1, $x) == 0) {
				return $y;
			}
		}
	}
	return 0;
}

#6
sub n_gl_x {
	my ($n, $x) = @_;

	### TODO
	for (my $y = 1; $y <= $x; $y++) {
		if(x_teilbar_y($x, $y)) {
			if(x_teilbar_y($x, (n_pr_x($n, $x) ** $y))) {
				if(!x_teilbar_y($x, (n_pr_x($n, $x) ** ($y + 1)))) {
					return $y;
				}
			}
		}
	}
	return 0;
}

#5
sub pr {
	my $n = shift;
	return nth_prime($n);
}

#4
sub faculty {
	my $n = shift ;
	my $product = 1 ;
	foreach my $i ( 1..$n ) {
		$product *= $i ;
	}
	return $product ;
}

#3
sub n_pr_x {
	my ($n, $x) = @_;
	return 0 if $n == 0;
	my @factors = factor($x);

	if($#factors < ($n - 1)) {
		warn "NOT ENOUGH FACTORS IN $x (".scalar(@factors)." FACTORS) TO GET THE $n th. RETURNING 0";
		return 0;
	} else {
		return $factors[$n - 1];
	}

}

#2
sub prim {
	my $x = shift;
	return !!is_prime($x);
}

# 1
sub x_teilbar_y {
	my ($x, $y) = @_;

	return 0 if $y == 0;
	return 1 unless $x % $y;
	return 0;
}

sub mytest {
	my $name = shift;
	my $is = shift;
	my $shouldbe = shift;

	my $str = "$name: ";
	if($is == $shouldbe) {
		$str .= color("green").("OK")
	} else {
		$str .= color("red").("ERROR. GOT $is, SHOULD BE $shouldbe")
	}
	$str .= color("reset")."\n";
	print $str;
}
