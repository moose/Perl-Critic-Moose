package Perl::Critic::Policy::Moose::RequireCleanNamespace;

use strict;
use warnings;

use Readonly ();

use Perl::Critic::Utils qw< :booleans :severities $PERIOD >;

use base 'Perl::Critic::Policy';

Readonly::Scalar my $EXPLANATION =>
    q<Don't leave things used for implementation in your interface.>;

sub supported_parameters {
    return (
        {
            name        => 'modules',
            description => 'The modules that need to be unimported.',
            default_string =>
                'Moose Moose::Role Moose::Util::TypeConstraints',
            behavior => 'string list',
        },
    );
}

sub default_severity { return $SEVERITY_MEDIUM; }
sub default_themes   { return qw( moose maintenance ); }
sub applies_to       { return 'PPI::Document' }

sub violates {
    my ( $self, undef, $document ) = @_;

    my %modules = ( use => {}, require => {}, no => {} );
    my $includes = $document->find('PPI::Statement::Include');
    return if not $includes;

    for my $include ( @{$includes} ) {
        $modules{ $include->type }->{ $include->module } = 1;
    }

    my $modules_to_unimport = $self->{_modules};
    my @used_but_not_unimported
        = grep { $modules_to_unimport->{$_} and not $modules{no}->{$_} }
        keys %{ $modules{use} };

    return if not @used_but_not_unimported;

    return $self->violation(
        q<Didn't unimport >
            . ( join q<, >, sort @used_but_not_unimported )
            . $PERIOD,
        $EXPLANATION,
        $document,
    );
}

1;

# ABSTRACT: Require removing implementation details from you packages.

__END__

=pod

=for stopwords unimport

=head1 AFFILIATION

This policy is part of L<Perl::Critic::Moose>.

=head1 DESCRIPTION

Anything in your namespace is part of your interface. The L<Moose> sugar is an
implementation detail and not part of what you want to support as part of your
functionality, especially if you may change your implementation to not use
Moose in the future. Thus, this policy requires you to say C<no Moose;> or
C<no Moose::Role;>, etc. as appropriate for modules you C<use>.

=head1 CONFIGURATION

By default, this module will complain if you C<use> L<Moose>, L<Moose::Role>,
or C<Moose::Util::TypeConstraints> but don't unimport them. You can set the
modules looked for using the C<modules> option.

    [Moose::RequireCleanNamespace]
    modules = Moose Moose::Role Moose::Util::TypeConstraints MooseX::My::New::Sugar


=head1 SEE ALSO

L<Moose::Manual::BestPractices>
