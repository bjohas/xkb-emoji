#!/usr/bin/perl
use warnings;
use strict;
use open IO => ':encoding(UTF-8)', ':std';
use utf8;
use feature qw{ say };
use 5.18.2;
use Encode;
use File::Slurp qw(read_file);
my $home = $ENV{HOME};
use Getopt::Long;
my $help = "";
my $encoding = "";
my $commentchar = "";
my $append = "";
GetOptions (
    "help" => \$help, 
    "encoding=s" => \$encoding,
    "commentchar=s" => \$commentchar,
    "append" => \$append,
    ) or die("Error in command line arguments\n");

if (!@ARGV || $help) {
    print("Need arguments");
say "
$0 [ --quotemethod x|U|U+|b ] [ --commentchar #|//|...] [--append] file [files]

Convert UTF characters to code points.

--encoding selects the 'encoding'/delimiters used for representing UTF code points.
   x   general perl quoting
   U   U1234-type quoting, suitable for xkb files.
   U+  U+1234
   b   curly brackets around code points.

--commentchar
   parts of lines following the char are not converted.

--append
   appends the chars that are converted. You need to set commentchar if you want
   this as part of a comment.

EXAMPLE

To generate an xkb symbols map, from a file that contains UTF8  character:

utf2codePoint.pl --encoding U --com '//' --app emoji-in >> /usr/share/X11/xkb/symbols/emoji


";
    exit;
};

use charnames ();
my @f;
my $a1 = "";
my $b1 = "";
my $a2 = "";
my $b2 = "";
my $qc = 0; # quote control. If 0, then control chars are passed through.
my $qm = 0; # quote meta. If 0, then characters are not quoted by \...

$a1 = "\\x{";
$b1 = "}";
$a2 = "\\x";
$b2 = "";
$qm = 1;
$qc = 1;


#{{{delimiter}}} Option added above
if ($encoding) {
    if ($encoding eq "x") {
	# default
    } elsif ($encoding eq "U") {
	$a1 = "U";
	$b1 = "";
	$a2 = "";
	$b2 = "";
	$qc = 0;
	$qm = 0;
    } elsif ($encoding eq "U+") {
	$a1 = "U+";
	$b1 = "";
	$a2 = "";
	$b2 = "";
	$qc = 0;
	$qm = 0;
    } elsif ($encoding eq "b") {
	$a1 = "{";
	$b1 = "}";
	$a2 = "{";
	$b2 = "}";
	$qm = 0;
	$qc = 1;
    } else {
	# default
    };
} else {
    # default
};

my $store = "";

foreach my $file (@ARGV) {
    @f = read_file($file);
    foreach (@f) {
	s/\n//;
	my $comment = "";
	if ($commentchar) {
	    if (s/($commentchar.*)$//) {
		$comment = decode_utf8($1);
	    };	    
	}
	$store = "";
	$_ = decode_utf8($_);
	$_ = &nice_string($_);
	if ($store) {
	    $store = $commentchar . " " . $store;
	    if ($comment) {
		$store = " " . $store;		
	    };
	};
	$_ .= $comment . $store . "\n";
    };
    say @f;
}

sub tee() {
    use charnames ();
    #say $_[0];
    $store .= charnames::string_vianame( "U+". $_[0] );
    return $_[0];
    
};

# https://perldoc.perl.org/perluniintro
sub nice_string {
    join("",
	 map { $_ > 255                                # if wide character...
		   ? $a1 . &tee(sprintf("%04X", $_)) . $b1   # \x{...}
		   :
		   (
		    chr($_) =~ /[[:cntrl:]]/          # else if control character...
		    ?
		    ( $qc
		      ? $a2 . sprintf("%02X", $_) . $b2   # \x..
		      : $a2 . chr($_) . $b2   
		    )
		    :
		    ( $qm
		      ? quotemeta(chr($_))        # else quoted or as themselves
		      : chr($_)
		    )
		   )		   
	 } unpack("W*", $_[0])                 # unpack Unicode characters
	);
}    




