#!/usr/local/bin/perl -w

use isa;

my $scalar = "";

%tests = ( HASH   => {},
	   ARRAY  => [],
	   SCALAR => \$scalar,
	   CODE   => \&isa,
	   GLOB   => \*STDIN
	 );

@tests = keys %tests;
$tests = 3 + (scalar @tests * scalar @tests);

print "1..$tests\n";

# Check classes

my $obj1 = bless {}, "Class1";
my $obj2 = bless {}, "Class2";

@Class2::ISA = qw(Class1);

print $obj1->isa("Class1") ? "ok" : "FAIL", " 1\n";
print $obj2->isa("Class1") ? "ok" : "FAIL", " 2\n";
print $obj1->isa("Class2") ? "FAIL" : "ok", " 3\n";

# Check for perl types

my $i = 4;

foreach $test (keys %tests) {
 foreach $type (keys %tests) {
  if($type eq $test) {
    print isa($tests{$test}, $type) ? "ok" : "FAIL", " $i\n";
  }
  else {
    print isa($tests{$test}, $type) ? "FAIL" : "ok", " $i\n";
  }
  $i++;
 }
}


