use strict;
use warnings;
use ExtUtils::MakeMaker;

my $eumm_version = $ExtUtils::MakeMaker::VERSION;
$eumm_version =~ s/_//;

WriteMakefile(
    NAME                => 'socketdaemon',
    AUTHOR              => q{Gary Greene <greeneg at tolharadys dot net>},
    VERSION_FROM        => 'lib/Socketd/Constants.pm',
    ABSTRACT            => 'The Socket Daemon collection of services',
    ($eumm_version >= 6.3001
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'socketdaemon-*' },
);

