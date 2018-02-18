#!/usr/bin/perl

use strict;

die "Usage: make-mutants.pl <path to assembly> [<function name>] [<debug>] or make-mutants.pl <path to assembly> [<debug>]"
  unless @ARGV >= 1;
my ($binary,$fn_name,$debug);
my $length = @ARGV;
$fn_name = "";

my $output;
if($length == 2) {
    ($binary, $debug) = @ARGV;
} elsif($length == 3) {
    ($binary, $fn_name, $debug) = @ARGV; 
}
open(F, $binary) or die;
my $curr_fn_name = "";
while (<F>) {
    if(/^[_a-zA-Z0-9.]+:$/ && !/^\..*/) {
	print "$_";
	chomp($_);
	$curr_fn_name = $_;
    }
    if($fn_name eq "" || ($curr_fn_name =~ /$fn_name/)) {
	my ($new_insn_0,$new_insn_1) = ("","");
	if(IsFlagUse($_)) {
	    $new_insn_0 = mutate($_, 0);
	    $new_insn_1 = mutate($_, 1);
	    print "new_insn_0 = $new_insn_0, new_insn_1 = $new_insn_1\n";
	}
    }
}
close F;


sub IsFlagUse {
    my ($insn) = (@_);
    if($insn =~ /\scmov/ || $insn =~ /\sset.*/ || ($insn =~ /\sj.*/ && !($insn =~ /\sjmp.*/))) {
	return 1;
    }
    return 0;
}

sub mutate {
    my($insn, $mutate_direction) = (@_);
    if($insn =~ /\scmov/) {
	if($mutate_direction == 0) {
	    $insn =~ s/cmov./mov/g;
	} elsif ($mutate_direction == 1) {
	    $insn = "nop";
	}
    }
    if($insn =~ /\sset/) {
	$insn =~ s/set../movb $mutate_direction, /g;
    }
    if ($insn =~ /\sj.*/ && !($insn =~ /\sjmp.*/)) {
	if($mutate_direction == 0) {
	    $insn =~ s/j../jmp/g;
	} elsif ($mutate_direction == 1) {
	    $insn = "nop";
	}
    }
    return $insn;
}
