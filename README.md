# NAME

Net::SSL::ExpireDate - obtain expiration date of certificate

# SYNOPSIS

    use Net::SSL::ExpireDate;

    $ed = Net::SSL::ExpireDate->new( https => 'example.com' );
    $ed = Net::SSL::ExpireDate->new( https => 'example.com:10443' );
    $ed = Net::SSL::ExpireDate->new( ssl   => 'example.com:465' ); # smtps
    $ed = Net::SSL::ExpireDate->new( ssl   => 'example.com:995' ); # pop3s
    $ed = Net::SSL::ExpireDate->new( file  => '/etc/ssl/cert.pem' );

    if (defined $ed->expire_date) {
      # do something
      $expire_date = $ed->expire_date;         # return DateTime instance

      $expired = $ed->is_expired;              # examine already expired

      $expired = $ed->is_expired('2 months');  # will expire after 2 months
      $expired = $ed->is_expired(DateTime::Duration->new(months=>2));  # ditto
    }

# DESCRIPTION

Net::SSL::ExpireDate get certificate from network (SSL) or local
file and obtain its expiration date.

# METHODS

## new

    $ed = Net::SSL::ExpireDate->new( %option )

This method constructs a new "Net::SSL::ExpireDate" instance and
returns it. %option is to specify certificate.

    KEY    VALUE
    ----------------------------
    ssl     "hostname[:port]"
    https   (same as above ssl)
    file    "path/to/certificate"
    timeout "Timeout in seconds"
    sni     "Server Name Indicator"

## expire\_date

    $expire_date = $ed->expire_date;

Return expiration date by "DateTime" instance.

## begin\_date

    $begin_date  = $ed->begin_date;

Return beginning date by "DateTime" instance.

## not\_after

Synonym for expire\_date.

## not\_before

Synonym for begin\_date.

## is\_expired

    $expired = $ed->is_expired;

Obtain already expired or not.

You can specify interval to obtain will expire on the future time.
Acceptable intervals are human readable string (parsed by
"Time::Duration::Parse") and "DateTime::Duration" instance.

    # will expire after 2 months
    $expired = $ed->is_expired('2 months');
    $expired = $ed->is_expired(DateTime::Duration->new(months=>2));

## type

return type of examinee certificate. "ssl" or "file".

## target

return hostname or path of examinee certificate.

# LIMITATIONS

This module supports the following TLS versions:

- 1.0 (SSL 3.1)
- 1.2

does not support the following TLS versions:

- 1.3

# BUGS

No bugs have been reported.

Please report any bugs or feature requests to
`bug-net-ssl-expiredate@rt.cpan.org`, or through the web interface at
[http://rt.cpan.org](http://rt.cpan.org).

# AUTHOR

HIROSE Masaaki &lt;hirose31 \_at\_ gmail.com>

# REPOSITORY

[http://github.com/hirose31/net-ssl-expiredate](http://github.com/hirose31/net-ssl-expiredate)

    git clone git://github.com/hirose31/net-ssl-expiredate.git

patches and collaborators are welcome.

# SEE ALSO

# COPYRIGHT & LICENSE

Copyright HIROSE Masaaki

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
