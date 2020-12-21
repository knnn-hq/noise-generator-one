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

my $runner = new Chuck::Runner;

$runner->start_chuck(@files);
