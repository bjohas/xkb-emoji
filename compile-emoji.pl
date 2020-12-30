#!/usr/bin/perl
use warnings;
use strict;
use open IO => ':encoding(UTF-8)', ':std';
use utf8;
use feature qw{ say };
use 5.18.2;

say("Preparing emoji file.");
system("utf2codePoint.pl --encoding U --comment '//' --app emoji-in > emoji-compiled");

say("To move emoji into place, run this:");
say("sudo cp -f emoji-compiled /usr/share/X11/xkb/symbols/emoji");

say "Note - just moving the file will not activate the emoji keyboard. You'll see to use setxkbmap or similar!";
exit();
