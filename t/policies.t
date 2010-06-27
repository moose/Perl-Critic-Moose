#!perl

#      $URL$
#     $Date$
#   $Author$
# $Revision$

use 5.008;  # Moose's minimum version.

use strict;
use warnings;

#-----------------------------------------------------------------------------

our $VERSION = '0.999_002';

#-----------------------------------------------------------------------------

use Test::Perl::Critic::Policy qw< all_policies_ok >;

my %args = @ARGV ? ( -policies => [ @ARGV ] ) : ();
all_policies_ok(%args);


# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# setup vim: set filetype=perl tabstop=4 softtabstop=4 expandtab :
# setup vim: set shiftwidth=4 shiftround textwidth=78 nowrap autoindent :
# setup vim: set foldmethod=indent foldlevel=0 :
