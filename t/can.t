#!/usr/local/bin/perl -w

use isa;

print "1..3\n";

# Check classes

my $obj1 = bless {}, "Class1";
my $obj2 = bless {}, "Class2";

@Class2::ISA = qw(Class1);

sub Class2::func2 { 1 }
sub Class1::func1 { 1 }

print $obj1->can("func1") ? "ok" : "FAIL", " 1\n";
print $obj2->can("func1") ? "ok" : "FAIL", " 2\n";
print $obj1->can("func2") ? "FAIL" : "ok", " 3\n";

