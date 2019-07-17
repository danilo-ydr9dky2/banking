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

Todos os testes podem ser executados com: `env $(cat .env.test) bundle exec rails test`.

## Deployment instructions

Copie o arquivo `.env.development.default` como `.env.development`.

`cp .env.development.default .env.development`

Edite as chaves secretas em `.env.development`. Dica: use `bundle exec rails secret` para gerar os segredos.

E, finalmente, execute o servidor com o seguinte comando:

`env $(cat .env.development) exec rails server`

## TODO

* implement a revocation policy for auth with JWT
* move away from a float type to represent amount
* implementar histórico de transfêrencias
* write documentation
* consider using dotenv gem to improve dev experience
