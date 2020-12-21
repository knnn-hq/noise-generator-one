#!/usr/bin/perl

use strict;
use warnings;

use File::Slurp;
use Path::Tiny;

unless ($#ARGV >= 0) {
    print "Usage: $0 <file.ck> [...files]\n";
    exit;
}

my @includes = ();
my %included_paths = ();

my %parsed_files = ();
my @parse_queue = ();

my $start_cwd = Path::Tiny->cwd();


foreach my $f (@ARGV) {
    if ($f =~ /ck$/i) {
        parse_file($f, $start_cwd, 0);
    }
    my $cmd = sprintf "chuck %s", build_cmd_line();
    system $cmd;
}

sub build_cmd_line {
    return join ' ', map { "\"$_\"" } map { $_->relative($start_cwd) } @includes;
}

sub parse_file {
    my ($file, $cwd, $level) = @_;

    my $log = sub {
        print("\t" x $level,  @_);
    };

    my $filepath = path($file)->absolute($cwd)->realpath;
    my $dirname = $filepath->parent->stringify;
    my $abspath = $filepath->stringify;

    &$log("Adding ", $filepath->basename);

    if (exists $included_paths{$abspath}) {
        print(" -- already added.\n");
        return;
    }
    
    unshift @includes, $filepath;
    $included_paths{$abspath} = 1;

    print(" --parsing...\n");

    my @content = read_file($filepath->stringify);
    foreach my $line (@content) {
        if ($line =~ m|^//\s*require\(["']?([^'"]+)["']?\)|i) {
            parse_file($1, $dirname, $level + 1);
        }
    }
}