package Perl::Critic::Policy::Moose::ProhibitLazyBuild;

use strict;
use warnings;

our $VERSION = '1.04';

use Readonly ();

use Perl::Critic::Utils qw< :booleans :severities >;
use Perl::Critic::Utils::PPI qw< is_ppi_generic_statement >;

use base 'Perl::Critic::Policy';
Readonly::Scalar my $DESCRIPTION => 'lazy_build is discouraged.';
Readonly::Scalar my $EXPLANATION =>
    q(lazy_build pollutes the namespace and encourages mutability.  See https://metacpan.org/pod/distribution/Moose/lib/Moose/Manual/BestPractices.pod#Avoid-lazy_build .);

sub supported_parameters {
    return (
        {
            name            => 'equivalent_modules',
            description     =>
                q<The additional modules to treat as equivalent to "Moose".>,
            default_string  => 'Moose Moose::Role MooseX::Role::Parameterized',
            behavior        => 'string list',
            list_always_present_values => [qw< Moose >],
        },
    );
}

sub default_severity     { return $SEVERITY_LOW; }
sub default_themes   { return qw< moose bugs >; }
sub applies_to       { return 'PPI::Document' }

sub prepare_to_scan_document {
    my ( $self, $document ) = @_;

    return $self->_is_interesting_document($document);
}

sub _is_interesting_document {
    my ( $self, $document ) = @_;

    foreach my $module ( keys %{ $self->{_equivalent_modules} } ) {
        return $TRUE if $document->uses_module($module);
    }

    return $FALSE;
}

sub violates {
    my ( $self, undef, $document ) = @_;

    my $uses_lazy_build = $document->find_any(
        sub {
            my ( undef, $element ) = @_;
            return $FALSE if not is_ppi_generic_statement($element);
            my $current_token = $element->schild(0);
            return $FALSE if not $current_token;
            return $FALSE if not $current_token->isa('PPI::Token::Word');
            return $FALSE if $current_token->content() ne 'has';
        my $parent = $current_token->parent;
        my $lazy_build = grep { $_->isa('PPI::Token::Word')
                    && $_->content() eq 'lazy_build' }
          $parent->tokens;
        return $lazy_build ? $TRUE : $FALSE;
     });
    return unless $uses_lazy_build;
    return $self->violation($DESCRIPTION, $EXPLANATION, $document);
}

1;

# ABSTRACT: Avoid lazy_build

__END__

=pod

=head1 AFFILIATION

This policy is part of L<Perl::Critic::Moose>.

=head1 DESCRIPTION

C< lazy_build => 1 > seemed like a good idea at the time, but it
creates problems (see
L<here|https://metacpan.org/pod/distribution/Moose/lib/Moose/Manual/BestPractices.pod#Avoid-lazy_build>).
This policy will complain if it finds lazy_build => 1 in your code.
