#      $URL$
#     $Date$
#   $Author$
# $Revision$

package Perl::Critic::Policy::Moose::ProhibitMultipleWiths;

use 5.008;  # Moose's minimum version.

use strict;
use warnings;


use Readonly ();

use Perl::Critic::Utils qw< :booleans :severities $EMPTY >;
use Perl::Critic::Utils::PPI qw< is_ppi_generic_statement >;

use base 'Perl::Critic::Policy';


Readonly::Scalar my $DESCRIPTION => 'Multiple calls to with() were made.';
Readonly::Scalar my $EXPLANATION =>
    q<Roles cannot protect against name conflicts if they are not composed.>;


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

sub default_severity     { return $SEVERITY_HIGH;           }
sub default_themes       { return qw( bugs moose roles );   }
sub applies_to           { return 'PPI::Document'           }


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

            my $with_statements = $subdocument->find(\&_is_with_statement);

            next SUBDOCUMENT if not $with_statements;
            next SUBDOCUMENT if @{ $with_statements } < 2;

            my $second_with = $with_statements->[1];
            push
                @violations,
                $self->violation($DESCRIPTION, $EXPLANATION, $second_with);
        } # end foreach
    } # end foreach

    return @violations;
} # end violates()


sub _is_with_statement {
    my (undef, $element) = @_;

    return $FALSE if not is_ppi_generic_statement($element);

    my $current_token = $element->schild(0);
    return $FALSE if not $current_token;
    return $FALSE if not $current_token->isa('PPI::Token::Word');
    return $FALSE if $current_token->content() ne 'with';

    return $TRUE;
} # edn _is_with_statement()


1;

# ABSTRACT: Require role composition

__END__

=pod


=head1 AFFILIATION

This policy is part of L<Perl::Critic::Moose>.


=head1 VERSION

This document describes Perl::Critic::Policy::Moose::ProhibitMultipleWiths
version 0.999_002.


=head1 DESCRIPTION

L<Moose::Role>s are, among other things, the answer to name conflicts plaguing
multiple inheritance and mix-ins. However, to enjoy this protection, you must
compose your roles together.  Roles do not generate conflicts if they are
consumed individually.

Pass all of your roles to a single L<with|Moose/with> statement.

    # ok
    package Foo;

    use Moose::Role;

    with qw< Bar Baz >;

    # not ok
    package Foo;

    use Moose::Role;

    with 'Bar';
    with 'Baz';


=head1 CONFIGURATION

There is a single option, C<equivalent_modules>.  This allows you to specify
modules that should be treated the same as L<Moose|Moose> and
L<Moose::Role|Moose::Role>, if, say, you were doing something with
L<Moose::Exporter|Moose::Exporter>.  For example, if you were to have this in
your F<.perlcriticrc> file:

    [Moose::ProhibitMultipleWiths]
    equivalent_modules = Foo Bar

then the following code would result in a violation:

    package Baz;

    use Bar;

    with 'Bing';
    with 'Bong';


=head1 SEE ALSO

L<http://search.cpan.org/dist/Moose/lib/Moose/Cookbook/Roles/Recipe2.pod>


=head1 BUGS AND LIMITATIONS

Please report any bugs or feature requests to
C<bug-perl-critic-moose@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


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
