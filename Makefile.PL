use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'Win32::MSI::HighLevel',
    VERSION_FROM => 'lib/Win32/MSI/HighLevel.pm', # finds \$VERSION
    AUTHOR       => 'Peter Jaquiery (grandpa@cpan.org)',
    ABSTRACT     => 'Perl wrapper for Windows Installer API',
    PREREQ_PM    => {
        'Win32::API' => 0.46,
        'Test::Pod::Coverage' => 0,
        'Test::Pod' => 0,
    },
);
