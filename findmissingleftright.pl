#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Term::ANSIColor;
use integer;

main();

sub main {
	my $text = slurp("goedel.tex");
	#$text = slurp("test3.tex");
	my @math_modes = get_math($text);
	my @missing_left_right = get_missing_left_right(@math_modes);

	my $count = scalar @missing_left_right;

	foreach my $missing (sort { length($b->{text}) <=> length($a->{text}) } @missing_left_right) {
		print "$missing->{text} at line $missing->{line}\n".("=" x 80)."\n";
	}

	print "Found $count math modes with missing \\left's\n";
}

sub get_missing_left_right {
	my @math_modes = @_;

	my $red = color("red");
	my $green = color("green");
	my $reset = color("reset");

	my $count = 0;
	my @missing_left_right = ();
	foreach my $math_mode (@math_modes) {
		my $line = $math_mode->{line};
		my $equation = $math_mode->{equation};

		if($equation =~ m#(?<!\\left)(\[|\(|\\\{)#) {
			my $type = $1;
			my $text = $equation;
			$text =~ s#^\s*##g;
			$text =~ s#(?<!\\left)(\Q$type\E)#$red$1$green#gism;
			push @missing_left_right, {
				text => $green.$text.$reset,
				line => $line
			};
			$count++;
		}
	}
	return @missing_left_right;
}

sub get_math {
	my $text = shift;
	my @math_modes = ();

	while ($text =~ m#(?<!\\)\$\$(.+?)\$\$#gis) {
		my $match = $1;
		my $original_match = $match;
		$match =~ s#^\R+##g;
		$match =~ s#\R+$##g;
		$match =~ s#^\s+$##g;
		my $pos = pos($text);
		push @math_modes, {
			equation => $match,
			line => pos_to_line($pos - length($original_match), $text)
		};
	}

	while ($text =~ m#(?<!\\|\$)\$(.+?)\$#gis) {
		my $match = $1;
		my $original_match = $match;
		$match =~ s#^\R+##g;
		$match =~ s#\R+$##g;
		$match =~ s#^\s+$##g;
		my $pos = pos($text);
		push @math_modes, {
			equation => $match,
			line => pos_to_line($pos - length($original_match), $text)
		};
	}

	while ($text =~ m#\\begin(\{(?:equation|aligned)\*?\})(.+?)\\end\1#gis) {
		my $match = $2;
		my $original_match = $match;
		$match =~ s#^\R+##g;
		$match =~ s#\R+$##g;
		$match =~ s#^\s+$##g;
		my $pos = pos($text);
		push @math_modes, {
			equation => $match,
			line => pos_to_line($pos - length($original_match), $text)
		};
	}

	@math_modes = map { $_ =~ s#\\(?:footnote|text)\{.*?\}##g; $_ } @math_modes;

	return @math_modes;
}

sub pos_to_line {
	my ($pos, $text) = @_;
	my $line = 1;

	my $string_to_pos = substr($text, 0, $pos);

	$line = ($string_to_pos =~ tr#\n##);
	$line++;
	return $line;
}

sub slurp {
	my $file = shift;
	my $contents = '';
	open my $fh, '<', $file or die $!;
	while (<$fh>) {
		$contents .= $_;
	}
	close $fh;
	return $contents;
}
