#      $URL: http://perlcritic.tigris.org/svn/perlcritic/trunk/Perl-Critic-Moose/lib/Perl/Critic/Policy/Moose/RequireMakeImmutable.pm $
#     $Date: 2008-10-30 09:36:26 -0500 (Thu, 30 Oct 2008) $
#   $Author: clonezone $
# $Revision: 2845 $

package Perl::Critic::Policy::Moose::RequireMakeImmutable;

use 5.008;  # Moose's minimum version.

use strict;
use warnings;

our $VERSION = '0.999_001';

use Readonly ();
use version ();

use Perl::Critic::Utils qw< :booleans :severities >;
use Perl::Critic::Utils::PPI qw< is_ppi_generic_statement >;

use base 'Perl::Critic::Policy';


Readonly::Scalar my $DESCRIPTION => 'No call was made to make_immutable().';
Readonly::Scalar my $EXPLANATION =>
    q<Moose can't optimize itself if classes remain mutable.>;


sub supported_parameters { return ();                       }
sub default_severity     { return $SEVERITY_MEDIUM;         }
sub default_themes       { return qw( moose performance );  }
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
            return $module eq 'Moose';
        }
    );
} # end prepare_to_scan_document()


sub violates {
    my ($self, undef, $document) = @_;

    my $imports = $document->find_any(
        sub {
            my (undef, $element) = @_;

            return $FALSE if not is_ppi_generic_statement($element);

            my $current_token = $element->schild(0);
            return $FALSE if not $current_token;
            return $FALSE if not $current_token->isa('PPI::Token::Word');
            return $FALSE if $current_token->content() ne '__PACKAGE__';

            $current_token = $current_token->snext_sibling();
            return $FALSE if not $current_token;
            return $FALSE if not $current_token->isa('PPI::Token::Operator');
            return $FALSE if $current_token->content() ne '->';

            $current_token = $current_token->snext_sibling();
            return $FALSE if not $current_token;
            return $FALSE if not $current_token->isa('PPI::Token::Word');
            return $FALSE if $current_token->content() ne 'meta';

            $current_token = $current_token->snext_sibling();
            return $FALSE if not $current_token;
            if ( $current_token->isa('PPI::Structure::List' ) ) {
                $current_token = $current_token->snext_sibling();
                return $FALSE if not $current_token;
            }

            return $FALSE if not $current_token->isa('PPI::Token::Operator');
            return $FALSE if $current_token->content() ne '->';

            $current_token = $current_token->snext_sibling();
            return $FALSE if not $current_token;
            return $FALSE if not $current_token->isa('PPI::Token::Word');
            return $FALSE if $current_token->content() ne 'make_immutable';

            return $TRUE;
        }
    );

    return if $imports;
    return $self->violation($DESCRIPTION, $EXPLANATION, $document);
} # end violates()


1;

__END__

=pod

=head1 NAME

Perl::Critic::Policy::Moose::RequireMakeImmutable - Make your Moose code fast.


=head1 AFFILIATION

This policy is part of L<Perl::Critic::Moose>.


=head1 VERSION

This document describes Perl::Critic::Policy::Moose::RequireMakeImmutable
version 0.999_001.


=head1 DESCRIPTION

L<Moose> is very flexible.  That flexibility comes at a performance cost.  You
can ameliorate most of it by telling Moose when you are done putting your
classes together.

Thus, if you C<use Moose>, this policy requires that you do
C<< __PACKAGE__->meta()->make_immutable() >>.


=head1 CONFIGURATION

This policy has no configuration options beyond the standard ones.


=head1 SEE ALSO

L<http://search.cpan.org/dist/Moose/lib/Moose/Cookbook/Basics/Recipe7.pod>


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
