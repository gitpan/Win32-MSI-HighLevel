use strict;
use warnings;

=head1 NAME

Win32::MSI::HighLevel::Handle - Helper module for Win32::MSI::HighLevel.

=head1 VERSION

Version 1.0001

=head1 AUTHOR

    Peter Jaquiery
    CPAN ID: GRANDPA
    grandpa@cpan.org

=head1 COPYRIGHT & LICENSE

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut

BEGIN {
    use Exporter ();
    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
    $VERSION     = '1.0001';
    @ISA         = qw(Exporter);
    @EXPORT      = qw();
    @EXPORT_OK   = qw();
    %EXPORT_TAGS = ();
}


package Win32::MSI::HighLevel::Handle;

use Win32::API;
use Win32::MSI::HighLevel::Common;
use Carp;

my $MsiCloseHandle = Win32::MSI::HighLevel::Common::_def(MsiCloseHandle => "I");
my $handleCount;

sub new {
    my ($type, $hdl, %params) = @_;
    my $class = ref $type || $type;

    croak "Internal error: handle required as first parameter to Handle->new"
        unless defined $hdl;

    $params{class} = $class;
    $params{handle} = $hdl =~ /^\d+$/ ? $hdl : unpack ("l", $hdl);
    ++$handleCount;
    return bless \%params, $class;
}


sub DESTROY {
    my $self = shift;

    if ($self->{handle}) {
        $self->{result} = $MsiCloseHandle->Call ($self->{handle});
        croak "Failed with error code $self->{result}"
            if $self->{result};
        --$handleCount;
    }

    $self->{handle} = 0;
}


sub null {
    return pack ("l",0);
}

END {
    die "Handle leak detected: $handleCount handles" if $handleCount;
}

1;
