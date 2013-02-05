use 5.012004;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Ecc12::EcCron',
    VERSION_FROM      => 'lib/Ecc12/EcCron.pm', # finds $VERSION
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Ecc12/EcCron.pm', # retrieve abstract from module
       AUTHOR         => 'Cameron King <cameron@ecc12.com>') : ()),
);
