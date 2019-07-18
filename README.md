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
env $(cat .env.development) bundle exec rails db:migrate
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

## HTTP API

### Usuário (*User*)

#### Criar um novo usuário: `POST /users`

**Autenticação**: não

**Sucesso**
```
POST /users
Body: {
  "name": "Alice",
  "email": "alice@email.com",
  "password": "secret"
}
Response status code: 200 OK
Response body: {
  "id": 1,
  "name": "Alice",
  "email": "alice@email.com",
  "created_at": "2019-07-18T13:33:44.476Z",
  "updated_at"=>"2019-07-18T13:33:44.476Z"
}
```

**Senha inválida**
```
POST /users
Body: {
  "name": "Alice",
  "email": "alice@email.com",
  "password": "short"
}
Response status code: 400 Bad Request
Response body: {
  "errors": {
    "password": ["is too short (minimum is 6 characters)"]
  }
}
```

**Email já cadastrado**
```
POST /users
Body: {
  "name": "Alice",
  "email": "alice@email.com",
  "password": "secret"
}
Response status code: 400 Bad Request
Response body: {
  "errors": {
    "email": ["email is already taken"]
  }
}
```

**Email inválido**
```
POST /users
Body: {
  "name": "Alice",
  "email": "aliceemail",
  "password": "secret"
}
Response status code: 400 Bad Request
Response body: {
  "errors": {
    "email": ["is invalid"]
  }
}
```

**Nome vazio**
```
POST /users
Body: {
  "name": "",
  "email": "alice@email.com",
  "password": "secret"
}
Response status code: 400 Bad Request
Response body: {
  "errors": {
    "name": ["can't be blank"]
  }
}
```

#### Obter usuário: `GET /users/:id`

**Autenticação**: sim

**Sucesso**
```
GET /users/1
Header: "Authorization: Bearer [token]"
Response status code: 200 OK
Response body: {
  "id": 1,
  "name": "Alice",
  "email": "alice@email.com",
  "created_at": "2019-07-18T13:33:44.476Z",
  "updated_at"=>"2019-07-18T13:33:44.476Z"
}
```

**Sem autorização**
```
GET /users/2
Header: "Authorization: Bearer [token for user 1]"
Response status code: 403 Forbidden
```

**Usuário inexistente**
```
GET /users/1
Header: "Authorization: Bearer [token]"
Response status code: 404 Not Found
```

#### Deletar usuário: `DELETE /users/:id` 

**Sucesso**
```
DELETE /users/1
Header: "Authorization: Bearer [token]"
Response status code: 204 No Content
```

**Usuário não existente**
```
DELETE /users/0
Header: "Authorization: Bearer [token]"
Response status code: 401 Unauthorized
```

**Sem autorização**
```
DELETE /users/2
Header: "Authorization: Bearer [token for user 1]"
Response status code: 403 Forbidden
```

### Sessão (*sign_in/sign_out*)

#### Fazer login: `POST /users/sign_in`

**Sucesso**

```
POST /users/sign_in
Body: {
  "user": {
    "email": "alice@email.com",
    "password": "secret"
  }
}
Response status code: 200 OK
Response header: "Authorization: Bearer [token]"
Response body: {
  "id": 1,
  "name": "Alice",
  "email": "alice@email.com",
  "created_at": "2019-07-18T13:33:44.476Z",
  "updated_at"=>"2019-07-18T13:33:44.476Z"
}
```

**Email ou senha incorretos**
```
POST /users/sign_in
Body: {
  "user": {
    "email": "alice@email.com",
    "password": "[wrong password]"
  }
}
Response status code: 401 Unauthorized
Response body: {
  "error": "Invalid Email or password."
}
```

#### Fazer logout: `DELETE /users/sign_out`

**Sucesso**

```
DELETE /users/sign_out
Header: "Authorization: Bearer [token]"
Response status code: 204 No Content
```

**Sem autenticação**
```
DELETE /users/sign_out
Response status code: 401 Unauthorized
Response body: {
  "error": "You need to sign in or sign up before continuing."
}
```

### Conta bancária (*Account*)

Todos os endpoints de conta bancária exigem **autenticação**.

#### Criar nova conta: `POST /users/:user_id/accounts`

**Sucesso**
```
POST /users/1/accounts
Header: "Authorization: Bearer [token]"
Response status code: 200 OK
Response body: {
  "id": 1,
  "user_id": 1,
  "balance": "0,00",
  "balance_in_cents": 0
  "created_at": "2019-07-18T14:01:33.362Z",
  "updated_at": "2019-07-18T14:01:33.362Z",
}
```

**Usuário inexistente**
```
POST /users/0/accounts
Header: "Authorization: Bearer [token]"
Response status code: 401 Unauthorized
```

**Sem autorização**
```
POST /users/2/accounts
Header: "Authorization: Bearer [token for user 1]"
Response status code: 403 Forbidden
```

#### Listar contas de um usuário: `GET /users/:user_id/accounts`

**Sucesso**
```
GET /users/1/accounts
Header: "Authorization: Bearer [token]"
Response status code: 200 OK
Response body: {
  "accounts": [
    {id: 1, user_id: 1, balance: "0,00", balance_in_cents: 0, created_at: ..., updated_at: ...},
    {id: 2, user_id: 1, balance: "0,00", balance_in_cents: 0, created_at: ..., updated_at: ...}
  ]
}
```

**Usuário inexistente**
```
GET /users/0/accounts
Header: "Authorization: Bearer [token]"
Response status code: 401 Unauthorized
```

**Sem autorização**
```
GET /users/2/accounts
Header: "Authorization: Bearer [token for user 1]"
Response status code: 403 Forbidden
```

#### Obter conta: `GET /accounts/:id`

**Sucesso**
```
GET /users/1/accounts
Header: "Authorization: Bearer [token]"
Response status code: 200 OK
Response body: {
  "id": 1,
  "user_id": 1,
  "balance": "0,00",
  "balance_in_cents": 0
  "created_at": "2019-07-18T14:01:33.362Z",
  "updated_at": "2019-07-18T14:01:33.362Z",
}
```

**Conta inexistente**
```
GET /accounts/0
Header: "Authorization: Bearer [token]"
Response status code: 401 Unauthorized
```

**Sem autorização**
```
GET /accounts/2
Header: "Authorization: Bearer [token for user who doesn't own this account]"
Response status code: 403 Forbidden
```

#### Deletar conta: `DELETE /accounts:id`

**Sucesso**
```
DELETE /accounts/1
Header: "Authorization: Bearer [token]"
Response status code: 204 No Content
```

**Conta inexistente**
```
DELETE /accounts/0
Header: "Authorization: Bearer [token]"
Response status code: 401 Unauthorized
```

**Sem autorização**
```
DELETE /accounts/2
Header: "Authorization: Bearer [token for user who doesn't own this account]"
Response status code: 403 Forbidden
```

#### Consultar saldo: `GET /accounts/:account_id/balance`

**Sucesso**
```
GET /accounts/1/balance
Header: "Authorization: Bearer [token]"
Response status code: 200 OK
Response body: {
  "balance": "0,00",
  "balance_in_cents": 0
}
```

**Conta inexistente**
```
GET /accounts/0/balance
Header: "Authorization: Bearer [token]"
Response status code: 401 Unauthorized
```

**Sem autorização**
```
GET /accounts/2/balance
Header: "Authorization: Bearer [token for user who doesn't own this account]"
Response status code: 403 Forbidden
```

#### Transferir dinheiro: `POST /accounts/:account_id/transfer/:destination_account_id`

**Sucesso**
```
POST /accounts/1/transfer/2
Header: "Authorization: Bearer [token]"
Body: { "amount": "10,01" }
Response status code: 200 OK
```

**Erro de formatação**
```
POST /accounts/1/transfer/2
Header: "Authorization: Bearer [token]"
Body: { "amount": "10,1" }
Response status code: 400 Bad Request
Response body: {
  "errors": ["amount must be in the format 9,99"]
}
```

**Sem autorização**
```
POST /accounts/1/transfer/2
Header: "Authorization: Bearer [token as user who doesn't own account 1]"
Body: { "amount": "10,01" }
Response status code: 403 Forbidden
```

**Saldo insuficiente**
```
POST /accounts/1/transfer/2
Header: "Authorization: Bearer [token]"
Body: { "amount": "1000,00" }
Response status code: 403 Forbidden
Response body: {
  "errors": ["source account has insufficient funds to proceed with this transaction"]
}
```

## Como contribuir

Para contribuir com este projeto, crie uma *issue* ou envie uma *pull request* com as mudanças sugeridas.

Aqui estão algumas melhorias que este projeto poderia ter:
* Usar [dotenv](https://github.com/bkeepers/dotenv) para faciliar o uso de variáveis de ambiente em desenvolvimento.
* Tornar as mensagens de erro consistentes entre si.
