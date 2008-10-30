#      $URL$
#     $Date$
#   $Author$
# $Revision$

package Perl::Critic::Policy::Moose::RequireCleanNamespace;

use 5.008;  # Moose's minimum version.

use strict;
use warnings;

our $VERSION = '0.999_001';

use Readonly ();
use version ();

use Perl::Critic::Utils qw< :booleans :severities >;

use base 'Perl::Critic::Policy';


Readonly::Scalar my $EXPLANATION =>
    q<Don't leave things used for implementation in your interface.>;


sub supported_parameters { return ();                       }
sub default_severity     { return $SEVERITY_MEDIUM;         }
sub default_themes       { return qw( moose maintenance );  }
sub applies_to           { return 'PPI::Document'           }


sub prepare_to_scan_document {
    my ($self, $document) = @_;

    return $document->find_any(
        sub {
            my (undef, $element) = @_;

            return $FALSE if not $element->isa('PPI::Statement::Include');
            return $FALSE if not $element->type() eq 'use';

            my $module = $element->module();
            return $FALSE if not $module;
            return $FALSE
                if not ($module eq 'Moose' or $module eq 'Moose::Role');

            $self->_set_module_to_unimport($module);
            return $TRUE;
        }
    );
} # end prepare_to_scan_document()


sub violates {
    my ($self, undef, $document) = @_;

    my $module_to_unimport = $self->_get_module_to_unimport();
    my $imports = $document->find_any(
        sub {
            my (undef, $element) = @_;

            return $FALSE if not $element->isa('PPI::Statement::Include');
            return $FALSE if not $element->type() eq 'no';

            my $module = $element->module();
            return $FALSE if not $module;

            return $module eq $module_to_unimport;
        }
    );

    return if $imports;
    return $self->violation(
        qq<Didn't unimport $module_to_unimport.>,
        $EXPLANATION,
        $document,
    );
} # end violates()


sub _get_module_to_unimport {
    my ($self) = @_;

    return $self->{_module_to_unimport};
} # end _get_module_to_unimport()

sub _set_module_to_unimport {
    my ($self, $module) = @_;

    $self->{_module_to_unimport} = $module;

    return;
} # end _set_module_to_unimport()


1;

__END__

=pod

=head1 NAME

Perl::Critic::Policy::Moose::RequireCleanNamespace - Require removing implementation details from you packages.


=head1 AFFILIATION

This policy is part of L<Perl::Critic::Moose>.


=head1 VERSION

This document describes Perl::Critic::Policy::Moose::RequireCleanNamespace
version 0.999_001.


=head1 DESCRIPTION

Anything in your namespace is part of your interface.  The L<Moose> sugar is
an implementation detail and not part of what you want to support as part of
your functionality, especially, if you may change your implementation to not
use Moose in the future.

Thus, if you C<use Moose> or C<use Moose::Role>, this policy requires that you
C<no Moose> or C<no Moose::Role>.


=head1 CONFIGURATION

This policy has no configuration options beyond the standard ones.


=head1 SEE ALSO

L<http://search.cpan.org/dist/Moose/lib/Moose/Cookbook/Style.pod#Clean_up_your_package>


=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-perl-critic-moose@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

Elliot Shank  C<< <perl@galumph.com> >>


=head1 COPYRIGHT

Copyright (c)2008, Elliot Shank C<< <perl@galumph.com> >>. Some rights
reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY FOR THE
SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN OTHERWISE
STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES PROVIDE THE
SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND
PERFORMANCE OF THE SOFTWARE IS WITH YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE,
YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING WILL ANY
COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR REDISTRIBUTE THE
SOFTWARE AS PERMITTED BY THE ABOVE LICENSE, BE LIABLE TO YOU FOR DAMAGES,
INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING
OUT OF THE USE OR INABILITY TO USE THE SOFTWARE (INCLUDING BUT NOT LIMITED TO
LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR
THIRD PARTIES OR A FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER
SOFTWARE), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGES.


=cut

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
