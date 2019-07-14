# Banking

Banking é um sistema que gerencia contas bancárias de clientes, permitindo fazer transferências de um cliente para outro e expor o saldo atual da conta, sempre em reais.

## Funcionalidades

## Versão de Ruby

Este sistema foi desenvolvido em `ruby 2.6.3`.

## Dependências

Execute `bundle install` para instalar todas as dependências.

## Configuração

TODO

## Criação de banco de dados

Caso o bando de dados ainda não exista, execute `bundle exec rails db:create` para criá-lo.

## Migrações de banco de dados

Mantenha as migrações de bando de dados atualizadas: `bundle exec rails db:migrate`.

## Testes

Todos os testes podem ser executados com: `bundle exec rails test`.

## Deployment instructions

`bundle exec rails server`.

## TODO

* implement authorization flow
* add AccountsController: POST, GET, DELETE
* add balance API
* add transfer API
* write documentation
