# Persisted Queries with graphql-ruby & Ruby on Rails

graphql-rubyを実装したRuby on Rails で事前に作成したクエリのみを許可するTrusted Document(Persisted Queries)のProof of Conceptを実装するためのコードサンプルです。

APQ(Automatic Persisted Queries) を実装するための [DmitryTsepelev/graphql-ruby-persisted_queries](https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries) とは異なり、事前に作成したクエリのみを実行許可します。

`graphql-codegen-persisted-query-ids` を使用し、クライアントアプリで使用するクエリを事前に生成し、サーバー側でそのQueryのみを許可するようにします。

## Trusted Documents
https://benjie.dev/graphql/trusted-documents

> GraphQL APIが自分自身のアプリのためだけのものである場合（ほとんどのGraphQL API！）、信頼できるドキュメントを使用することで、攻撃対象が大幅に減少し、パフォーマンスが向上し、帯域幅の使用量が減少します。 アプリのビルド時に、GraphQLドキュメント（クエリーなど）を抽出し、サーバーで利用できるようにします。実行時に、ドキュメント全体の代わりにdocumentIdを送信し、documentIdを持つリクエストのみを受け入れる。

**参照**
- https://www.youtube.com/watch?v=ZZ5PF3_P_r4

## 構築
```bash
# gem をinstall
bundle install

# Railsを起動する
bin/rails s

# Railsを起動する(Persisted Queryのみを受け付けるようにする場合)
GRAPHQL_PERSISTED_QUERY_REQUIRED=1 bin/rails s
```

http://localhost:3000/graphql にアクセスする

## クエリの生成
0. npm installを実行する
```bash
npm install
```

1. src配下のjsファイルでクエリを作成する

2. codegenを実行する
```bash
npm run codegen
```


## リクエストサンプル
```bash
# Query

## Normal Query with POST
curl -X POST 'http://localhost:3000/graphql' \
  -H 'Content-Type: application/json' \
  --data-raw '{"operationName":"Query1","query":"query Query1 { __typename}"}'

## Persisted Query with GET data-urlencode
curl --get http://localhost:3000/graphql \
  --data-urlencode 'extensions={"persistedQuery":{"version":1,"sha256Hash":"bfa62138163a76dca4f6c317779a0954b768b00e9268f6639db90d78633986aa"}}' \
  --data-urlencode 'operationName=Query1'

## Persisted Query with GET param
curl --get 'http://localhost:3000/graphql?operationName=Query1&extensions=%7B%22persistedQuery%22%3A%7B%22version%22%3A1%2C%22sha256Hash%22%3A%22bfa62138163a76dca4f6c317779a0954b768b00e9268f6639db90d78633986aa%22%7D%7D'

## Persisted Query with POST
curl -X POST 'http://localhost:3000/graphql' \
  -H 'Content-Type: application/json' \
  --data-raw '{"operationName":"Query1","extensions":{"persistedQuery":{"version":1,"sha256Hash":"bfa62138163a76dca4f6c317779a0954b768b00e9268f6639db90d78633986aa"}}}'


# Mutation

# Normal Query Mutation with POST
curl -X POST 'http://localhost:3000/graphql' \
  -H 'Content-Type: application/json' \
  --data-raw '{"operationName":"TestMutation", "query":"mutation TestMutation { testField }"}'

# Persisted Query Mutation with POST
curl -X POST 'http://localhost:3000/graphql' \
  -H 'Content-Type: application/json' \
  --data-raw '{"operationName":"TestMutation","extensions":{"persistedQuery":{"version":1,"sha256Hash":"d020631ba2da76821646d798387621cabfc709e911aa263e25c833119fb627ad"}}}'

# Persisted Query Mutation with GET param (Failure Case)
curl --get http://localhost:3000/graphql \
  --data-urlencode 'extensions={"persistedQuery":{"version":1,"sha256Hash":"d020631ba2da76821646d798387621cabfc709e911aa263e25c833119fb627ad"}}' \
  --data-urlencode 'operationName=TestMutation'

```


## 環境
macOS上にruby, nodeがインストールされていることを前提としています。 

**rails環境** 
- Ruby 3.3.0
- Rails 7.1.3
- graphql-ruby, "~> 2.3"

**codegen環境**
- node.js v18.17.0
- npm 9.6.7
- graphql-code-generator, "^0.18.2",
- graphql-codegen-persisted-query-ids, "^0.1.2"
