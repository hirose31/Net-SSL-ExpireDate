package Net::SSL::ExpireDate;

use strict;
use warnings;
use Carp;

our $VERSION = '1.04';

use base qw(Class::Accessor);
use IO::Socket::SSL;
use Net::SSLeay;
use Crypt::OpenSSL::X509;
use Date::Parse;
use DateTime;
use DateTime::Duration;
use Time::Duration::Parse;

__PACKAGE__->mk_accessors(qw(type target));

BEGIN {
    my $debug_flag = $ENV{SMART_COMMENTS} || $ENV{SMART_COMMENT} || $ENV{SMART_DEBUG} || $ENV{SC};
    if ($debug_flag) {
        my @p = map { '#'x$_ } ($debug_flag =~ /([345])\s*/g);
        use UNIVERSAL::require;
        Smart::Comments->use(@p);
    }
}

sub new {
    my ($class, %opt) = @_;

    my $self = bless {
        type        => undef,
        target      => undef,
        expire_date => undef,
       }, $class;

    if ( $opt{https} or $opt{ssl} ) {
        $self->{type}   = 'ssl';
        $self->{target} = $opt{https} || $opt{ssl};
    } elsif ($opt{file}) {
        $self->{type}   = 'file';
        $self->{target} = $opt{file};
        if (! -r $self->{target}) {
            croak "$self->{target}: $!";
        }
    } else {
        croak "missing option: neither ssl nor file";
    }

    return $self;
}

sub expire_date {
    my $self = shift;

    if (! $self->{expire_date}) {
        if ($self->{type} eq 'ssl') {
            my ($host, $port) = split /:/, $self->{target}, 2;
            $port ||= 443;
            ### $host
            ### $port
            my $sock = IO::Socket::SSL->new("$host:$port");
            croak IO::Socket::SSL::errstr() if ! $sock;
            my $cert = $sock->peer_certificate();

            my $expire_date_asn1 = Net::SSLeay::X509_get_notAfter($cert);
            my $expire_date_str  = Net::SSLeay::P_ASN1_UTCTIME_put2string($expire_date_asn1);
            ### $expire_date_str
            my $begin_date_asn1  = Net::SSLeay::X509_get_notBefore($cert);
            my $begin_date_str   = Net::SSLeay::P_ASN1_UTCTIME_put2string($begin_date_asn1);
            ### $begin_date_str

            $sock->close;

            $self->{expire_date} = DateTime->from_epoch(epoch => str2time($expire_date_str));
            $self->{begin_date}  = DateTime->from_epoch(epoch => str2time($begin_date_str));

        } elsif ($self->{type} eq 'file') {
            my $x509 = Crypt::OpenSSL::X509->new_from_file($self->{target});
            $self->{expire_date} = DateTime->from_epoch(epoch => str2time($x509->notAfter));
            $self->{begin_date}  = DateTime->from_epoch(epoch => str2time($x509->notBefore));
        } else {
            croak "unknown type: $self->{type}";
        }
    }

    return $self->{expire_date};
}

sub begin_date {
    my $self = shift;

    if (! $self->{begin_date}) {
        $self->expire_date;
    }

    return $self->{begin_date};
}

*not_after  = \&expire_date;
*not_before = \&begin_date;

sub is_expired {
    my ($self, $duration) = @_;
    $duration ||= DateTime::Duration->new();

    if (! $self->{begin_date}) {
        $self->expire_date;
    }

    if (! ref($duration)) { # if scalar
        $duration = DateTime::Duration->new(seconds => parse_duration($duration));
    }

    my $dx = DateTime->now()->add_duration( $duration );
    ### dx: $dx->iso8601

    return DateTime->compare($dx, $self->{expire_date}) >= 0 ? 1 : ();
}


1; # Magic true value required at end of module
__END__

=head1 NAME

Net::SSL::ExpireDate - obtain expiration date of certificate

=head1 SYNOPSIS

    use Net::SSL::ExpireDate;

    $ed = Net::SSL::ExpireDate->new( https => 'example.com' );
    $ed = Net::SSL::ExpireDate->new( https => 'example.com:10443' );
    $ed = Net::SSL::ExpireDate->new( ssl   => 'example.com:465' ); # smtps
    $ed = Net::SSL::ExpireDate->new( ssl   => 'example.com:995' ); # pop3s
    $ed = Net::SSL::ExpireDate->new( file  => '/etc/ssl/cert.pem' );

    $expire_date = $ed->expire_date;         # return DateTime instance

    $expired = $ed->is_expired;              # examine already expired

    $expired = $ed->is_expired('2 months');  # will expire after 2 months
    $expired = $ed->is_expired(DateTime::Duration->new(months=>2));  # ditto

=head1 DESCRIPTION

Net::SSL::ExpireDate get certificate from network (SSL) or local
file and obtain its expiration date.

=head1 METHODS

=head2 new

  $ed = Net::SSL::ExpireDate->new( %option )

This method constructs a new "Net::SSL::ExpireDate" instance and
returns it. %option is to specify certificate.

  KEY    VALUE
  ----------------------------
  ssl    "hostname[:port]"
  https  (same as above ssl)
  file   "path/to/certificate"

=head2 expire_date

  $expire_date = $ed->expire_date;

Return expiration date by "DateTime" instance.

=head2 begin_date

  $begin_date  = $ed->begin_date;

Return beginning date by "DateTime" instance.

=head2 not_after

Synonym for expire_date.

=head2 not_before

Synonym for begin_date.

=head2 is_expired

  $expired = $ed->is_expired;

Obtain already expired or not.

You can specify interval to obtain will expire on the future time.
Acceptable intervals are human readable string (parsed by
"Time::Duration::Parse") and "DateTime::Duration" instance.

  # will expire after 2 months
  $expired = $ed->is_expired('2 months');
  $expired = $ed->is_expired(DateTime::Duration->new(months=>2));

=head2 type

return type of examinee certificate. "ssl" or "file".

=head2 target

return hostname or path of examinee certificate.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-net-ssl-expiredate@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

=head1 AUTHOR

HIROSE Masaaki  C<< <hirose31@gmail.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2006, HIROSE Masaaki C<< <hirose31@gmail.com> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

