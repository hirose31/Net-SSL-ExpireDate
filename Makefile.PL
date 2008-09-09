use inc::Module::Install;

name     'Net-SSL-ExpireDate';
all_from 'lib/Net/SSL/ExpireDate.pm';

requires 'Class::Accessor'       => 0;
requires 'IO::Socket'            => 0;
requires 'Crypt::OpenSSL::X509'  => 0;
requires 'Date::Parse'           => 0;
requires 'DateTime'              => 0;
requires 'DateTime::Duration'    => 0;
requires 'Time::Duration::Parse' => 0;

build_requires 'Test::More'      => 0;

use_test_base;
auto_install;
WriteAll;
