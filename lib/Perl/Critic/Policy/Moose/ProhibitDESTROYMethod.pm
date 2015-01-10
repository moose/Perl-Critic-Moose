package Perl::Critic::Policy::Moose::ProhibitDESTROYMethod;

use strict;
use warnings;

use Readonly ();

use Perl::Critic::Utils qw< :booleans :severities $EMPTY >;

use base 'Perl::Critic::Policy';

Readonly::Scalar my $DESCRIPTION =>
    q<"DESTROY" method/subroutine declared in a Moose class.>;
Readonly::Scalar my $EXPLANATION => q<Use DEMOLISH for your destructors.>;

sub supported_parameters {
    return (
        {
            name => 'equivalent_modules',
            description =>
                q<The additional modules to treat as equivalent to "Moose".>,
            default_string             => $EMPTY,
            behavior                   => 'string list',
            list_always_present_values => [qw< Moose Moose::Role >],
        },
    );
}

sub default_severity { return $SEVERITY_MEDIUM; }
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

    my @violations;
    foreach my $namespace ( $document->namespaces() ) {
    SUBDOCUMENT:
        foreach my $subdocument (
            $document->subdocuments_for_namespace($namespace) ) {
            next SUBDOCUMENT
                if not $self->_is_interesting_document($subdocument);

            if ( my $destructor
                = $subdocument->find_first( \&_is_destructor ) ) {
                push
                    @violations,
                    $self->violation(
                    $DESCRIPTION, $EXPLANATION,
                    $destructor
                    );
            }
        }
    }

    return @violations;
}

sub _is_destructor {
    my ( undef, $element ) = @_;

    return $FALSE if not $element->isa('PPI::Statement::Sub');

    return $element->name() eq 'DESTROY';
}

1;

# ABSTRACT: Use DEMOLISH instead of DESTROY

__END__

=pod

=for stopwords destructor

=head1 AFFILIATION

This policy is part of L<Perl::Critic::Moose>.

=head1 DESCRIPTION

Getting the order of destructor execution correct with inheritance involved is
difficult. Let L<Moose> take care of it for you by putting your cleanup code
into a C<DEMOLISH()> method instead of a C<DESTROY()> method.

    # ok
    package Foo;

    use Moose::Role;

    sub DEMOLISH {
        ...
    }

    # not ok
    package Foo;

    use Moose::Role;

    sub DESTROY {
        ...
    }

=head1 CONFIGURATION

There is a single option, C<equivalent_modules>. This allows you to specify
modules that should be treated the same as L<Moose> and L<Moose::Role>, if,
say, you were doing something with L<Moose::Exporter>. For example, if you
were to have this in your F<.perlcriticrc> file:

    [Moose::ProhibitDESTROYMethod]
    equivalent_modules = Foo Bar

then the following code would result in a violation:

    package Baz;

    use Bar;

    sub DESTROY {
        ...
    }

=head1 SEE ALSO

L<Moose::Manual::Construction>
