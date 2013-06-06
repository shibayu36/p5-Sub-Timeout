package Sub::Timeout;
use 5.008005;
use strict;
use warnings;

our $VERSION = "0.01";

use Time::HiRes qw(alarm);
use Scalar::Util ();
use Exporter::Lite;

our @EXPORT = qw(timeout);

sub timeout {
    my ($time, $code, $timeout_cb) = @_;

    local $@;
    my $res = eval {
        _timeout($time, $code);
    };
    alarm 0;

    my $e = $@;
    return $res unless $e;

    if (Scalar::Util::blessed($e) && $e->isa('Sub::Timeout::Error') && $timeout_cb) {
        return $timeout_cb->();
    }
    else {
        die $e;
    }
}

sub _timeout {
    my ($time, $code) = @_;

    local $SIG{ALRM} = sub {
        Sub::Timeout::Error->throw("Timeout. $time seconds.");
    };
    alarm $time;

    my $res = $code->();

    alarm 0;

    return $res;
}

package
    Sub::Timeout::Error;
use strict;
use warnings;

use overload
    '""' => \&as_string,
    fallback => 1;

sub new {
    my ($class, $message) = @_;
    return bless { message => $message }, $class;
}

sub throw {
    my ($class, $message) = @_;
    die $class->new($message);
}

sub as_string {
    my ($self) = @_;
    return $self->{message};
}

1;
__END__

=encoding utf-8

=head1 NAME

Sub::Timeout - It's new $module

=head1 SYNOPSIS

    use Sub::Timeout;

=head1 DESCRIPTION

Sub::Timeout is ...

=head1 LICENSE

Copyright (C) shibayu36.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

shibayu36 E<lt>shibayu36@gmail.comE<gt>

=cut

