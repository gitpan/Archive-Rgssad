use strict;
use warnings;
use Archive::Rgssad;
use Archive::Rgssad::Entry;
use Digest::MD5 'md5_hex';
use IO::Scalar;
use List::Util 'first';
use Test::More tests => 8;

my $prefix = "t/sample";
my $rgssad = Archive::Rgssad->new;

sub readfile {
  my $file = shift;
  local $/ = undef;
  open FH, '<', $file;
  binmode FH;
  return <FH>;
  close FH;
}

while (my $path = <DATA>) {
  chomp($path);
  my $data = readfile("$prefix/$path");
  $rgssad->add($path, $data);
}

my $buf;

my $out = IO::Scalar->new(\$buf);
$rgssad->save($out);
my @entries = $rgssad->entries;
is(md5_hex($buf), '4c77ecfb07a93a54802bc7f86822b868', 'save');

my $in = IO::Scalar->new(\$buf);
$rgssad->load($in);
my @entries2 = $rgssad->entries;
cmp_ok(@entries2, '==', @entries, 'number of entries');

for my $entry (@entries) {
  my $entry2 = first { $_->path eq $entry->path } @entries2;
  is($entry2->path, $entry->path, 'path of ' . $entry->path);
  is($entry2->data, $entry->data, 'data of ' . $entry->path);
}

1;

__DATA__
Dummy
Data/Scripts.rvdata
Graphics/System/1x1.png
