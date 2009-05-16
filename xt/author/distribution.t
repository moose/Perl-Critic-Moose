#!/usr/bin/env perl

#      $URL$
#     $Date$
#   $Author$
# $Revision$

# Taken from
# http://www.chrisdolan.net/talk/index.php/2005/11/14/private-regression-tests/.

use 5.008;  # Moose's minimum version.

use strict;
use warnings;

our $VERSION = '0.999_002';

# No POD coverage due to complaints about builtins when using Fatal.
use Test::Distribution ( distversion => 1, not => 'podcover' );

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
