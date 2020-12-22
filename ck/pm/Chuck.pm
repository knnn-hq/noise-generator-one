## Chuck - helpers for working with ChucK
package Chuck;

use strict;
use warnings;
use Carp;

use File::Slurp;
use Path::Tiny;

BEGIN {
	use Exporter ();
	our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);

	$VERSION     = '0.0.1';
	@ISA         = qw(Exporter);
	@EXPORT      = ();
	%EXPORT_TAGS = ();
	@EXPORT_OK   = ();
}
my $pkg_name = 'Chuck';

sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;
    my $self = bless {}, $class;
	my %params = @_;

    $self->{chuck} = $params{chuck} || 'chuck';

	return $self;
}

1;
