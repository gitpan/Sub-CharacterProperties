package Sub::CharacterProperties;

use strict;
use warnings;
use Number::Rangify 'rangify';
use charnames ':full';


use base qw(Class::Accessor::Complex Data::Inherited);


__PACKAGE__
    ->mk_new
    ->mk_array_accessors(qw(characters));


our $VERSION = '0.01';


sub get_ranges {
    my $self = shift;

    # Convert the values to their actual Unicode character equivalent.  For
    # defining a character, we accept Unicode character names (the "..." part
    # of the "\N{...}" notation) or hex code points (indicated by a leading
    # "0x"; useful for characters that don't have a name).

    my @characters;
    for ($self->characters) {
        if (/^0x(.*)$/) {
            push @characters => sprintf '%c' => hex($1);
        } else {
            push @characters => sprintf '%c' => charnames::vianame($_);
        }
        utf8::upgrade($_);
    }

    my @ranges = rangify(map { ord($_) } @characters);
    wantarray ? @ranges : \@ranges;
}


sub as_code {
    my ($self, $name) = @_;

    $name = 'InFoo' unless defined $name;


    my $code = "sub $name { <<'END' }\n";

    for my $range ($self->get_ranges) {
        my ($lower, $upper) = $range->Size;
        if ($lower == $upper) {
            $code .= sprintf "%X\n", $lower;
        } else {
            $code .= sprintf "%X %X\n", $lower, $upper;
        }
    }

    $code .= "END\n";
    $code;
}


1;


__END__

=head1 NAME

Sub::CharacterProperties - support for user-defined character properties

=head1 SYNOPSIS

    my $n = Sub::CharacterProperties->new(characters => [
        'LATIN SMALL LETTER A',
        'LATIN SMALL LETTER B',
        'LATIN SMALL LETTER C',
        'LATIN SMALL LETTER D',
        ...
    ]);
    print $n->as_code('MySet');

=head1 DESCRIPTION

As described in L<perlunicode>, you can define your own character properties.
To do so, you need to specify the ranges of allowed characters as pairs of
hexadecimal numbers. There are easier ways of combining ranges with C<+>,
C<->, C<!> and C<&>, but if you have a diverse set of characters you are
going to have to deal with hex values.

This module aims at making your task of writing these character property
subroutines easier.

Basically you create an object of this class, pass it a list of the Unicode
character names of the characters you'd like to allow and then have it
generate the character property subroutine.

The character property subroutines are a compile-time feature, so
unfortunately this module can't just install the generated subroutine. You
will have to copy-and-paste it into your program.

=head1 METHODS

=over 4

=item new

Constructs a new object. See L<Class::Accessor::Complex>'s C<mk_new> for
features of this constructor.

=item characters

The list of characters you would like to allow. See
L<Class::Accessor::Complex>'s C<mk_array_accessors> for details about which
methods are available.

Each character should be either a Unicode character name - such as C<LATIN
SMALL LETTER A> - or a hex code point - indicated by a leading "0x" - this is
useful for characters that don't have a name.

=item get_ranges

Assumes that the C<characters()> have been set.

Returns a list of ranges containing character numeric values; each range is a
L<Set::IntRange> object.

=item as_code

Assumes that the C<characters()> have been set.

Returns, as a string, the code of the subroutine you can use to implement your
custom character properties.

Takes an optional string argument; this is used for the subroutine name. Note
that according to L<perlunicode> the subroutine name has to start with C<In>
or C<Is>. If this argument is omitted, a dummy name - C<InFoo> - is used.

=back

=head1 TAGS

If you talk about this module in blogs, on del.icio.us or anywhere else,
please use the C<setcharacterproperties> tag.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-set-characterproperties@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

=head1 INSTALLATION

See perlmodinstall for information and options on installing Perl modules.

=head1 AVAILABILITY

The latest version of this module is available from the Comprehensive Perl
Archive Network (CPAN). Visit <http://www.perl.com/CPAN/> to find a CPAN
site near you. Or see <http://www.perl.com/CPAN/authors/id/M/MA/MARCEL/>.

=head1 AUTHOR

Marcel GrE<uuml>nauer, C<< <marcel@cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright 2007 by Marcel GrE<uuml>nauer

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

