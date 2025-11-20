#!/usr/bin/env perl

use strict;
use warnings;
use Carp;
use IPC::Open2;
# use HTML::Escape;  # (CPAN) HTML::Escape
# use DDP;


sub escape_html {
  $_ = shift;
  s/&/&amp;/g;
  s/</&lt;/g;
  s/>/&gt;/g;
  s/'"'/&quot;/g;
  return $_;
}

my @bindsyms = 
  grep(/^bindsym/, # only `bindsym`-s.
       grep(!/(^#)|(^\s*$)/, # omit comment or empty lines.
            qx<i3-msg -t get_config>));

chomp @bindsyms;

map { s/^bindsym //g } @bindsyms;

my @key_to_cmd = map {
  my @m = $_ =~ /^(?<key>\S+)\s+(?<cmd>.+)$/;
  \@m;
} @bindsyms;

my @dmenu_items = map {
  my ($key, $cmd) = ($_->[0], $_->[1]);

  $key = escape_html($key);
  $key = "<span size='large' weight='heavy'>$key</span>";

  $cmd = escape_html($cmd);
  $cmd = "\t\t$cmd";

  my $result = join "\n", $key, $cmd;
  $result .= "\0";
  $result;
} @key_to_cmd;

# p @dmenu_items;

my $pid = open2(
  my $stdout, my $stdin,
  "rofi -dmenu -p 'i3 keybindings' -sep '\\0' -eh 2 -markup-rows -format i"
 ) or confess;

foreach (@dmenu_items) {
  print $stdin $_;
  # print $_;
}
close($stdin);

my $stdout_ = do { local($/); <$stdout> };
close($stdout);

waitpid($pid, 0);
my $exit_code = $? >> 8;
# print STDERR "exit_code: $exit_code\n";

if ($exit_code == 0) {
  chomp $stdout_;
  my $cmd = $key_to_cmd[$stdout_]->[1];
  print STDERR "STDOUT: [$stdout_] => [$cmd]\n";
  `i3-msg '$cmd'`;
} else {
  print STDERR "EXIT: $exit_code\n";
}
