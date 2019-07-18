# Banking

Banking é um sistema que gerencia contas bancárias de clientes, permitindo fazer transferências de uma conta bancária para outra e expor o saldo atual da conta.

## Funcionalidades

### Funcionalidade #1: Transferir dinheiro

Entrada: `<source_account_id>`, `<destination_account_id>`, `<amount>`

O valor `<amount>` é transferido da conta de origem `<source_account_id>` para a conta de destinado `<destination_account_id>`. Caso a conta de origem não possua saldo suficiente, a transferência é cancelada.

### Funcionalidade #2: Consultar saldo

Entrada: `<account_id>`

Retorna saldo atual da conta que é calculado baseado no histórico de transferência.

## Versão de Ruby

Este sistema foi desenvolvido em `ruby 2.6.3`.

## Dependências

Execute `bundle install` para instalar todas as dependências.

* Ruby 2.6.3
* PostgreSQL 11.2
* Bundler 2.0.2

## Configuração

* Instale [Ruby](https://www.ruby-lang.org/pt/documentation/installation/) na versão 2.6.3 ou superior.
* Instale [PostgreSQL](https://www.postgresql.org/download/) na versão 11.2 ou superior.
* Instale [Bundler](https://bundler.io/) com o comando `gem install bundle`

### Ambiente de desenvolvimento

Copie o arquivo `.env.development.default` como `.env.development` e edite as chaves secretas em `.env.development`.

```
cp .env.development.default .env.development
```

### Banco de dados

Execute o seguinte comando para criar o banco de dados e executar todas as migrações pendentes.

```
env $(cat .env.development) bundle exec rails db:setup
```

### Migrações de banco de dados

Para manter as migrações de bando de dados atualizadas, execute o seguinte comando. Note que `rails db:setup` já vai ter executado todas as migrações pendentes no passo anterior, então você pode pular este passo durante a configuração inicial.

```
`env $(cat .env.development) bundle exec rails db:migrate
```

## Testes

Todos os testes podem ser executados com:

```
env $(cat .env.test) bundle exec rails test
```

## Deployment

### Ambiente de desenvolvimento

Para iniciar o servidor em modo desenvolvimento:

```
env $(cat .env.development) exec rails server
```

Os arquivos de log estarão disponíveis em `log/development.log`.

### Ambiente de produção

Configure o ambiente de produção usando o arquivo `.env.production` para definir as variáveis de ambiente. Edite as chaves secretas em `.env.production`. Dica: use `bundle exec rails secret` para gerar os segredos.

Instale as dependências e configure o banco de dados como no ambiente de desenvolvimento. Lembre-se de usar o arquivo `.env.production` para definir as variáveis de ambiente.

## TODO

* write documentation
* consider using dotenv gem to improve dev experience
