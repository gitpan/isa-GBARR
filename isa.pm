
package isa;

$VERSION  = sprintf("%d.%02d", q$Revision: 1.1 $ =~ /(\d+)\.(\d+)/);

require DynaLoader;

@ISA = qw(DynaLoader);

#
# Only bootstrap if we are imported (ie use isa), this allows us to
# require isa inside Makefile.PL without first built isa.so
#

my $booted = 0; # bootstrap only once;

sub import {
 bootstrap isa $VERSION
   unless $booted;

 *{(caller)[0] . "::isa"} = \&UNIVERSAL::isa;

 $booted = 1;
}

1;

