#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install 1.02;
use Module::Install::Catalyst; # Complain loudly if you don't have
                               # Catalyst::Devel installed or haven't said
                               # 'make dist' to create a standalone tarball.

name 'PerlPro-Web';
all_from 'lib/PerlPro/Web.pm';

requires 'Catalyst::Runtime' => '5.90042';
requires 'Catalyst::Plugin::Params::Nested';
requires 'Catalyst::Plugin::Session';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Session::Store::File';
requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Plugin::Authorization::Roles';
requires 'Catalyst::Authentication::Store::DBIx::Class';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Component::InstancePerContext';
requires 'HTML::Entities';
requires 'Text::Unaccent::PurePerl';
requires 'Data::Manager';
requires 'Moose';
requires 'MooseX::Types::Email';
requires 'MooseX::Types::Moose';
requires 'MooseX::Types::URI';
requires 'namespace::autoclean';
requires 'Config::General';
requires 'DBD::Pg';
requires 'DBIx::Class';
requires 'DBIx::Class::EncodedColumn';
requires 'DateTime::Format::Pg';
requires 'Crypt::Eksblowfish::Bcrypt';
requires 'Catalyst::Model::DBIC::Schema';
requires 'Text::Xslate';
requires 'HTML::FillInForm';
requires 'Catalyst::View::Xslate';
requires 'Catalyst::View::JSON';
test_requires 'Test::More' => '0.88';
test_requires 'pQuery';
test_requires 'Test::WWW::Mechanize::Catalyst';
test_requires 'WWW::Mechanize::TreeBuilder';
catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
