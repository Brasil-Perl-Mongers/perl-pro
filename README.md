# perlpro

Catálogo de vagas de emprego para programadores Perl no Brasil, assim como divulgação do perfil de empresas e uso que fazem da linguagem Perl.

**Visite nossa [wiki](https://github.com/Brasil-Perl-Mongers/perl-pro/wiki) para acompanhar o desenvolvimento do layout!**

Para o deploy do banco de dados, primeiro crie o banco de dados no PostgreSQL, e depois atualize suas credenciais em sqitch.conf. Em seguida:

    $ cpanm App::Sqitch
    $ sqitch deploy
