package Perl::Critic::Policy::Moose::ProhibitNewMethod;

use strict;
use warnings;

use Readonly ();

use Perl::Critic::Utils qw< :booleans :severities >;
use Perl::Critic::Utils::PPI qw< is_ppi_generic_statement >;

use base 'Perl::Critic::Policy';

Readonly::Scalar my $DESCRIPTION =>
    q<"new" method/subroutine declared in a Moose class.>;
Readonly::Scalar my $EXPLANATION =>
    q<Use BUILDARGS and BUILD instead of writing your own constructor.>;

sub supported_parameters { return (); }
sub default_severity     { return $SEVERITY_HIGH; }
sub default_themes       { return qw< moose bugs >; }
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

    my $constructor = $document->find_first(
        sub {
            my ( undef, $element ) = @_;

            return $FALSE if not $element->isa('PPI::Statement::Sub');

            return $element->name() eq 'new';
        }
    );

    return if not $constructor;
    return $self->violation( $DESCRIPTION, $EXPLANATION, $constructor );
}

1;

# ABSTRACT: Don't override Moose's standard constructors.

__END__

=pod

=head1 AFFILIATION

This policy is part of L<Perl::Critic::Moose>.

=head1 DESCRIPTION

Overriding C<new()> on a L<Moose> class causes a number of problems, including
speed issues and problems with order of invocation of constructors when
multiple inheritance is involved. Use C<BUILDARGS()> and C<BUILD()> instead.

=head1 CONFIGURATION

This policy has no configuration options beyond the standard ones.

=head1 SEE ALSO

=over 4

=item * L<Moose::Manual::Construction>

=item * L<Moose::Manual::BestPractices>

=back
