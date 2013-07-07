# perlpro

Catálogo de vagas de emprego para programadores Perl no Brasil, assim como divulgação do perfil de empresas e uso que fazem da linguagem Perl.

**Visite nossa [wiki](https://github.com/Brasil-Perl-Mongers/perl-pro/wiki) para acompanhar o desenvolvimento do layout!**

## Instalação

Para o deploy do banco de dados, primeiro crie o banco de dados no PostgreSQL, e utilize [sqitch](http://sqitch.org):

    $ cpanm App::Sqitch             # ou cpanm -n App::Sqitch, se estiver com pressa :)
    $ sqitch config -e --local      # ou abra sqitch.conf em seu editor favorito
    $ sqitch deploy

Depois disso, configure a aplicação:

    $ cp perlpro_web_local.conf-example perlpro_web_local.conf
    $ $EDITOR perlpro_web_local.conf

Por fim, instale dependências e ponha o site no ar:

    $ cpanm --installdeps .
    $ plackup

Pronto!

Para depuração e uma maior facilidade ao desenvolvimento, você pode utilizar, ao invés de plackup:

    $ ./script/perlpro_web_server -dr
