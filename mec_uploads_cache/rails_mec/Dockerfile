# FROM golang:1.16

# WORKDIR /go/src

# COPY ./mec_uploads_cache /go/src/

# RUN go build

# CMD ["go", "run", "server.go"]

FROM ruby:3.0.3
# ベースにするイメージを指定

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs default-mysql-client vim
# RUN bundle install

# RailsのインストールやMySQLへの接続に必要なパッケージをインストール

RUN mkdir /app
# コンテナ内にmyappディレクトリを作成

WORKDIR /app
# 作成したmyappディレクトリを作業用ディレクトリとして設定

COPY ./Gemfile /app/Gemfile
COPY ./Gemfile.lock /app/Gemfile.lock
# ローカルの Gemfile と Gemfile.lock をコンテナ内のmyapp配下にコピー

RUN bundle install
# コンテナ内にコピーした Gemfile の bundle install

COPY ./ /app
# ローカルのmyapp配下のファイルをコンテナ内のmyapp配下にコピー