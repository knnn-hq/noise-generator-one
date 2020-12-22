## Chuck - helpers for working with ChucK
package Chuck::Runner;

use strict;
use warnings;

use Carp;

use File::Slurp;
use Path::Tiny;

require Chuck;

our $VERSION = '0.1';
our @ISA     = qw(Chuck);

sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;
	my %params = @_;

	my $self = $class->SUPER::new();
	bless ($self, $class);

    $self->{chuck_args} = $params{chuch_args} || '';

    $self->{shreds} = ();
    $self->{cwd} = Path::Tiny->cwd();
    $self->{dependencies} = {};

	return $self;
}


sub start_chuck {
    my ($self, @files) = @_;

    $self->{cwd} = Path::Tiny->cwd;

    return $self
        ->_add_dependencies(\@files)
        ->_update_chuck_shreds()
        ->_run_chuck_command();
}

### Will parse files multiple times, which has the benefit of not requiring
### special logic to figure out dependency graphs :D
sub _add_dependencies {
    my ($self, $files, $cwd, $level) = @_;  

    $cwd   = $self->{cwd} unless (defined $cwd);   
    $level = 0 unless (defined $level);


    foreach my $file (@$files) {
        my $filepath = path($file)->absolute($cwd)->realpath;
        my $dirname = $filepath->parent->stringify;
        my $abspath = $filepath->stringify;

        $self->{dependencies}->{$abspath} = $level;
        
        my @content = read_file($abspath);
        my @included_files = ();
        
        foreach my $line(@content) {
            # eg // #include "file/script.ck"
            if ($line =~ m{ ^// \s* \#include \s+ ["'] ([^'"]+) ["'] }xi) {
                push @included_files, $1;
            }
        }

        $self->_add_dependencies(\@included_files, $dirname, $level + 1);
    }

    return $self;
}

sub _run_chuck_command {
    my ($self) = @_;
    system join(' ', $self->{chuck}, $self->{chuck_args}, @{$self->{chuck_shreds}});

    return $self;
}

sub _update_chuck_shreds {
    my ($self) = @_;
    my @files = map { "\"$_\"" } map { path($_)->relative($self->{cwd})->stringify } sort { 
        $self->{dependencies}->{$b} <=> $self->{dependencies}->{$a} 
    } keys %{$self->{dependencies}};

    $self->{chuck_shreds} = \@files;

    return $self;
}

1;
