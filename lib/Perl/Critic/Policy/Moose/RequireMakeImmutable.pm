package Perl::Critic::Policy::Moose::RequireMakeImmutable;

use strict;
use warnings;

use Readonly ();

use Perl::Critic::Utils qw< :booleans :severities >;
use Perl::Critic::Utils::PPI qw< is_ppi_generic_statement >;

use base 'Perl::Critic::Policy';

Readonly::Scalar my $DESCRIPTION => 'No call was made to make_immutable().';
Readonly::Scalar my $EXPLANATION =>
    q<Moose can't optimize itself if classes remain mutable.>;

sub supported_parameters { return (); }
sub default_severity     { return $SEVERITY_MEDIUM; }
sub default_themes       { return qw( moose performance ); }
sub applies_to           { return 'PPI::Document' }

sub prepare_to_scan_document {
    my ( $self, $document ) = @_;

    # Tech debt: duplicate code.
    return $document->find_any(
        sub {
            my ( undef, $element ) = @_;

            return $FALSE if not $element->isa('PPI::Statement::Include');
            return $FALSE if not $element->type() eq 'use';

            my $module = $element->module();
            return $FALSE if not $module;
            return $module eq 'Moose';
        }
    );
}

sub violates {
    my ( $self, undef, $document ) = @_;

    my $makes_immutable = $document->find_any(
        sub {
            my ( undef, $element ) = @_;

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
            if ( $current_token->isa('PPI::Structure::List') ) {
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

    return if $makes_immutable;
    return $self->violation( $DESCRIPTION, $EXPLANATION, $document );
}

1;

# ABSTRACT: Ensure that you've made your Moose code fast

__END__

=pod

=head1 AFFILIATION

This policy is part of L<Perl::Critic::Moose>.

=head1 DESCRIPTION

L<Moose> is very flexible. That flexibility comes at a performance cost. You
can ameliorate some of that cost by telling Moose when you are done putting
your classes together.

Thus, if you C<use Moose>, this policy requires that you do
C<< __PACKAGE__->meta()->make_immutable() >>.

=head1 CONFIGURATION

This policy has no configuration options beyond the standard ones.
