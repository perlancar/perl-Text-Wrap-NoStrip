package Text::Wrap::NoStrip;

use strict;
use warnings;

use Exporter qw(import);

# AUTHORITY
# DATE
# DIST
# VERSION

our @EXPORT_OK = qw(
                       wrap
               );

our $columns = 76;

sub wrap {
    my $initial_indent = shift;
    my $subsequent_indent = shift;

    my @res = ($initial_indent);
    my $width = length($initial_indent);
    my $si_len = length($subsequent_indent);

    for my $text (@_) {
        my @chunks = split /(\R+|\s+)/, $text;
        #use DD; dd \@chunks;
        for my $chunk (@chunks) {
            if ($chunk =~ /\R/) {
                $width = 0;
                push @res, $chunk;
            } else {
              L1:
                my $len = length $chunk;
                #print "D:got chunk=<$chunk> ($len), width=$width, scalar(\@res)=".scalar(@res)."\n";
                if ($width + $len > $columns) {

                    # should we chop long word?
                    if ($chunk !~ /\s/ && $len > $columns - $si_len) {
                        my $s = substr($chunk, 0, $columns - $width);
                        #print "D:wrapping <$s>\n";
                        substr($chunk, 0, $columns - $width) = "";
                        push @res, $s, "\n$subsequent_indent";
                        $width = $si_len;
                        goto L1;
                    } else {
                        push @res, "\n$subsequent_indent", $chunk;
                        $width = $len;
                    }
                } else {
                    #print "D:adding <$chunk>\n";
                    push @res, $chunk;
                    $width += $len;
                }
            }
            #print "D:width=$width\n";
        }
    }

    join("", @res);
}

1;
# ABSTRACT: Line wrapping without stripping the whitespace

=head1 SYNOPSIS

Use like you would use L<Text::Wrap> (but currently only C<$columns> variable is
supported):

 use Text::Wrap::NoStrip qw(wrap);
 $Text::Wrap::NoStrip::columns = 80; # default 76
 print wrap('', '  ', @text);


=head1 DESCRIPTION

NOTE: Early implementaiton, no tab handling.

This module provides C<wrap()> variant that does not strip the whitespaces, to
make unfolding easier and capable of returning the original text. Contrast:

 # original $text
 longwordlongwordlongword word   word   word word

 # wrapped by Text::Wrap::wrap('', 'x', $text), with added quotes
 # 123456789012
 "longwordlongw"
 "xordlongword"
 "xword   word"
 "xword word"

 # wrapped by Text::Wrapp::NoStrip::wrap('', ' ', $text)
 "longwordlongw"
 "xordlongword"
 "x word   word"
 "x   word word"

To get back the original $text, you can do:

 ($text = $wrapped) =~ s/\nx//g;


=head1 FUNCTIONS

=head2 wrap

Usage:

 wrap($initial_indent, $subsequent_indent, @text); # => str


=head1 SEE ALSO

L<Text::Wrap>

Other wrapping modules, see L<Acme::CPANModules::TextWrapping>.

=cut
