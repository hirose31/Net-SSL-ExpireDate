# -*- mode: cperl; -*-
use Test::Dependencies
    exclude => [qw(Test::Dependencies Test::Base Test::Perl::Critic
                   Net::SSL::ExpireDate)],
    style   => 'light';
ok_dependencies();
