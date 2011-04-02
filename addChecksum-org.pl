#!/usr/bin/perl

# Copyright 2011 Wladimir Palant
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#############################################################################
# This is a reference script to add checksums to downloadable               #
# subscriptions. The checksum will be validated by Adblock Plus on download #
# and checksum mismatches (broken downloads) will be rejected.              #
#                                                                           #
# To add a checksum to a subscription file, run the script like this:       #
#                                                                           #
#   perl addChecksum.pl subscription.txt                                    #
#                                                                           #
# Note: your subscription file should be saved in UTF-8 encoding, otherwise #
# the generated checksum might be incorrect.                                #
#                                                                           #
#############################################################################

use strict;
use warnings;
use Digest::MD5 qw(md5_base64);

die "Usage: $^X $0 subscription.txt\n" unless @ARGV;

my $file = $ARGV[0];
my $data = readFile($file);

# Remove already existing checksum
$data =~ s/^.*!\s*checksum[\s\-:]+([\w\+\/=]+).*\n//gmi;

# Calculate new checksum: remove all CR symbols and empty
# lines and get an MD5 checksum of the result (base64-encoded,
# without the trailing = characters).
my $checksumData = $data;
$checksumData =~ s/\r//g;
$checksumData =~ s/\n+/\n/g;

# Calculate new checksum
my $checksum = md5_base64($checksumData);

# Insert checksum into the file
$data =~ s/(\r?\n)/$1! Checksum: $checksum$1/;

writeFile($file, $data);

sub readFile
{
  my $file = shift;

  open(local *FILE, "<", $file) || die "Could not read file '$file'";
  binmode(FILE);
  local $/;
  my $result = <FILE>;
  close(FILE);

  return $result;
}

sub writeFile
{
  my ($file, $contents) = @_;

  open(local *FILE, ">", $file) || die "Could not write file '$file'";
  binmode(FILE);
  print FILE $contents;
  close(FILE);
}
