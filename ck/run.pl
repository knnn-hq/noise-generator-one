#!/usr/bin/perl
use strict;
use warnings;

use lib './pm';

use Chuck::Runner;

my @files = grep { m|^[^\-].+\.ck$|i } @ARGV;

if ($#files < 0) {
    print "$0 <file.ck> [...more-files]\n";
    exit;
}

my $runner = new Chuck::Runner(
	chuck_args => '--bufsize:8192 --channels:1 --srate:44100'
);

$runner->start_chuck(@files);
