use strict;
use warnings;
use Test::More;

=head1 NAME

HighLevel test suite

=head1 DESCRIPTION

Test Win32::MSI::HighLevel

=cut

BEGIN {
    use lib '../lib';
    use_ok("Win32::MSI::HighLevel");
}

if ( $^O eq 'MSWin32' ) {
    plan('no_plan');
} else {
    plan( skip_all => "Windows only module. Tests irrelevant on $^O" );
}

my $filename = 'delme.msi';

# Basic create and open database tests.
unlink $filename;
ok(
    my $msi = Win32::MSI::HighLevel->new(
        -file => $filename,
        -mode => Win32::MSI::HighLevel::Common::kMSIDBOPEN_CREATE
    ),
    'Create a new .msi file in transacted mode'
);
$msi = 0;    # Destroy object

unlink $filename;
ok(
    $msi = Win32::MSI::HighLevel->new(
        -file => $filename,
        -mode => Win32::MSI::HighLevel::Common::kMSIDBOPEN_CREATEDIRECT
    ),
    'Create a new .msi file in direct mode'
);
$msi = 0;    # Destroy object

ok(
    $msi = Win32::MSI::HighLevel->new(
        -file => $filename,
        -mode => Win32::MSI::HighLevel::Common::kMSIDBOPEN_DIRECT
    ),
    'Open existing .msi file in direct mode'
);
$msi = 0;    # Destroy object

ok(
    $msi = Win32::MSI::HighLevel->new(
        -file => $filename,
        -mode => Win32::MSI::HighLevel::Common::kMSIDBOPEN_READONLY
    ),
    'Open existing .msi file in read only mode'
);
$msi = 0;    # Destroy object

ok(
    $msi = Win32::MSI::HighLevel->new(
        -file => $filename,
        -mode => Win32::MSI::HighLevel::Common::kMSIDBOPEN_TRANSACT
    ),
    'Open existing .msi file in transacted mode'
);

print "Create a Feature table, populate it, and check contents\n";
is(
    'Feature',
    $msi->createTable( -table => 'Feature' ),
    'Create Feature table'
);
is(
    'Complete',
    $msi->addFeature( -name => 'Complete', -Title => 'Full install' ),
    'Add Complete feature to Feature table'
);
mustDie( '"Complete" eq $msi->addFeature ()', 'Add empty feature fails' );
ok( $msi->writeTables(), 'Write updated tables to disk' );

is( 0, $msi->exportTable( 'Feature', 'Tables' ), 'Export Feature table' );

checkTableEntry(
    'Feature',
    <<"FEATURE", {
Feature\tFeature_Parent\tTitle\tDescription\tDisplay\tLevel\tDirectory_\tAttributes
s38\tS38\tL64\tL255\tI2\ti2\tS72\ti2
Feature\tFeature
Complete\t\tFull install\t\t1\t3\t\t0
FEATURE
        1 => 'Column names',
        2 => 'Column specs',
        3 => 'Table name and keys',
        4 => 'Row data',
    }
);

print "Create a Property table, populate it, and check contents\n";
is(
    'Property',
    $msi->createTable( -table => 'Property' ),
    'Create Property table'
);
is(
    'Wibble',
    $msi->addProperty( -Property => 'Wibble', -Value => 'wobble' ),
    'Add Wibble property to Property table'
);
mustDie( '"Property" eq $msi->addProperty ()', 'Add empty property fails' );
ok( $msi->writeTables(), 'Write updated tables to disk' );
is( 0, $msi->exportTable( 'Property', 'Tables' ), 'Export Property table' );

checkTableEntry(
    'Property',
    <<"PROPERTY", {
Property\tValue
s72\tl0
Property\tProperty
Wibble\twobble
PROPERTY
        1 => 'Column names',
        2 => 'Column specs',
        3 => 'Table name and keys',
        4 => 'Row data',
    }
);

$msi = 0;    # Destroy object

unlink $filename;
exit;

sub checkTableEntry {
    my ( $tableName, $data, $testLines ) = @_;
    my @lines     = split /\n/, $data;
    my $lineIndex = 0;
    my $tablePath = File::Spec->rel2abs("Tables\\$tableName.idt");

    $testLines->{$_} = [ $lines[ $lineIndex++ ], $testLines->{$_} ]
      for sort keys %$testLines;

    ok(
        ( my $result = open( my $inFile, '<', $tablePath ) ),
        "Open $tableName table file for validation"
    );
    if ( !$result ) {
        print "Open $tablePath failed: $!\n";
        return;
    }

    while (<$inFile>) {
        next unless exists $testLines->{$.};
        chomp;
        chomp $testLines->{$.}[0];
        is( $_, $testLines->{$.}[0], "$tableName table: $testLines->{$.}[1]" );
    }

    ok( close($inFile), "Close $tableName table file\n" );
}

sub mustDie {
    my ( $test, $name ) = @_;

    eval $test;
    ok( defined $@, $name );
}
