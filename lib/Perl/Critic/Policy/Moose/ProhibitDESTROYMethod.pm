#      $URL$
#     $Date$
#   $Author$
# $Revision$

package Perl::Critic::Policy::Moose::ProhibitDESTROYMethod;

use 5.008;  # Moose's minimum version.

use strict;
use warnings;

our $VERSION = '0.999_002';

use Readonly ();

use Perl::Critic::Utils qw< :booleans :severities $EMPTY >;

use base 'Perl::Critic::Policy';


Readonly::Scalar my $DESCRIPTION =>
    q<"DESTROY" method/subroutine declared in a Moose class.>;
Readonly::Scalar my $EXPLANATION =>
    q<Use DEMOLISH for your destructors.>;


sub supported_parameters {
    return (
        {
            name            => 'equivalent_modules',
            description     =>
                q<The additional modules to treat as equivalent to "Moose".>,
            default_string  => $EMPTY,
            behavior        => 'string list',
            list_always_present_values => [ qw< Moose Moose::Role > ],
        },
    );
} # end supported_parameters()

sub default_severity     { return $SEVERITY_MEDIUM; }
sub default_themes       { return qw< moose bugs >; }
sub applies_to           { return 'PPI::Document'   }


sub prepare_to_scan_document {
    my ($self, $document) = @_;

    return $self->_is_interesting_document($document);
} # end prepare_to_scan_document()


sub _is_interesting_document {
    my ($self, $document) = @_;

    foreach my $module ( keys %{ $self->{_equivalent_modules} } ) {
        return $TRUE if $document->uses_module($module);
    } # end foreach

    return $FALSE;
} # end _is_interesting_document()


sub violates {
    my ($self, undef, $document) = @_;

    my @violations;
    foreach my $namespace ( $document->namespaces() ) {
        SUBDOCUMENT:
        foreach my $subdocument (
            $document->subdocuments_for_namespace($namespace)
        ) {
            next SUBDOCUMENT
                if not $self->_is_interesting_document($subdocument);

            if (
                my $destructor = $subdocument->find_first(\&_is_destructor)
            ) {
                push
                    @violations,
                    $self->violation($DESCRIPTION, $EXPLANATION, $destructor);
            } # end if
        } # end foreach
    } # end foreach

    return @violations;
} # end violates()


sub _is_destructor {
    my (undef, $element) = @_;

    return $FALSE if not $element->isa('PPI::Statement::Sub');

    return $element->name() eq 'DESTROY';
} # end _is_destructor()


1;

__END__

=pod

=for stopwords destructor


=head1 NAME

Perl::Critic::Policy::Moose::ProhibitDESTROYMethod - Use DEMOLISH instead of DESTROY.


=head1 AFFILIATION

This policy is part of L<Perl::Critic::Moose|Perl::Critic::Moose>.


=head1 VERSION

This document describes Perl::Critic::Policy::Moose::ProhibitDESTROYMethod
version 0.999_002.


=head1 DESCRIPTION

Getting the order of destructor execution correct with inheritance involved is
difficult.  Let L<Moose|Moose> take care of it for you by putting your cleanup
code into a C<DEMOLISH()> method instead of a C<DESTROY()> method.

    # ok
    package Foo;

    use Moose::Role;

    sub DEMOLISH {
        ...
    } # end DEMOLISH()

    # not ok
    package Foo;

    use Moose::Role;

    sub DESTROY {
        ...
    } # end DESTROY()


=head1 CONFIGURATION

There is a single option, C<equivalent_modules>.  This allows you to specify
modules that should be treated the same as L<Moose|Moose> and
L<Moose::Role|Moose::Role>, if, say, you were doing something with
L<Moose::Exporter|Moose::Exporter>.  For example, if you were to have this in
your F<.perlcriticrc> file:

    [Moose::ProhibitDESTROYMethod]
    equivalent_modules = Foo Bar

then the following code would result in a violation:

    package Baz;

    use Bar;

    sub DESTROY {
        ...
    } # end DESTROY()


=head1 SEE ALSO

L<http://search.cpan.org/dist/Moose/lib/Moose/Manual/Construction.pod>


=head1 BUGS AND LIMITATIONS

Please report any bugs or feature requests to
C<bug-perl-critic-moose@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

Elliot Shank  C<< <perl@galumph.com> >>


=head1 COPYRIGHT

Copyright (c)2009, Elliot Shank C<< <perl@galumph.com> >>. Some rights
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
