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

use Perl::Critic::Utils qw< :booleans :severities $PERIOD >;

use base 'Perl::Critic::Policy';


Readonly::Scalar my $EXPLANATION =>
    q<Don't leave things used for implementation in your interface.>;


sub supported_parameters {
    return (
        {
            name            => 'modules',
            description     => 'The modules that need to be unimported.',
            default_string  =>
                'Moose Moose::Role Moose::Util::TypeConstraints',
            behavior        => 'string list',
        },
    );
}

sub default_severity     { return $SEVERITY_MEDIUM;         }
sub default_themes       { return qw( moose maintenance );  }
sub applies_to           { return 'PPI::Document'           }


sub violates {
    my ($self, undef, $document) = @_;

    my %modules = ( use => {}, require => {}, no => {} );
    my $includes = $document->find('PPI::Statement::Include');
    return if not $includes;

    for my $include ( @{$includes} ) {
        $modules{$include->type}->{$include->module} = 1;
    } # end for

    my $modules_to_unimport = $self->{_modules};
    my @used_but_not_unimported =
        grep { $modules_to_unimport->{$_} and not $modules{no}->{$_} }
        keys %{ $modules{use} };

    return if not @used_but_not_unimported;

    return $self->violation(
        q<Didn't unimport > . (join q<, >, sort @used_but_not_unimported) . $PERIOD,
        $EXPLANATION,
        $document,
    );
} # end violates()


1;

__END__

=pod

=for stopwords unimport

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
your functionality, especially if you may change your implementation to not
use Moose in the future.  Thus, this policy requires you to say C<no Moose;>
or C<no Moose::Role;>, etc. as appropriate for modules you C<use>.


=head1 CONFIGURATION

By default, this module will complain if you C<use> L<Moose>, L<Moose::Role>,
or C<Moose::Util::TypeConstraints> but don't unimport them.  You can set the
modules looked for using the C<modules> option.

    [Moose::RequireCleanNamespace]
    modules = Moose Moose::Role Moose::Util::TypeConstraints MooseX::My::New::Sugar


=head1 SEE ALSO

L<http://search.cpan.org/dist/Moose/lib/Moose/Manual/BestPractices.pod#no_Moose_and_immutabilize>


=head1 BUGS AND LIMITATIONS

Right now this assumes that you've only got one C<package> statement in your
code.  It will get things wrong if you create multiple classes in a single
file.

This doesn't support using L<namespace::clean>.

Please report any bugs or feature requests to
C<bug-perl-critic-moose@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

Elliot Shank  C<< <perl@galumph.com> >>


=head1 COPYRIGHT

Copyright (c)2008-2009, Elliot Shank C<< <perl@galumph.com> >>. Some rights
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
# setup vim: set shiftwidth=4 shiftround textwidth=78 autoindent :
# setup vim: set foldmethod=indent foldlevel=0 :
