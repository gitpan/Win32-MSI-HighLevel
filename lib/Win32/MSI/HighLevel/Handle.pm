use strict;
use warnings;

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
