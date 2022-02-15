# 実験手順方法

## 準備

### デバイス側
---


### MECサーバー
---
dockerで環境を構築しているので下記のコマンドで対象のサーバーで構築できる.
構成は,rails,mysql,nginxとなっている.
```
docker compose up --build
```
ただし, https化を行うためdockerを起動する前に証明書とドメインを取得してください.

### 転送するクラウド
---
本実験ではDropboxを使用した.
よってDropboxの設定を説明する.

1. Dropboxでアクセスし, アプリケーションを作成する.
1. Dropboxの権限を変更し,files.content.write,files.content.read, files.metadata.readを許可する
1. App key, App secretを控えておく
  
一旦Dropbox側の設定が完了した.

## 直接アップロード
---
https://github.com/andreafabrizi/Dropbox-Uploader を使用してアップロードをおこなった.詳しくはDropbox-UploaderのREADMEを参照して転送をおこなう.

## MECを経由するアップロードするための準備

1. ユーザ登録を行う. `https://{取得したドメイン}/users/sign_up` でemailとパスワードを設定する.
次回以降のログインは`https://{取得したドメイン}/users/sign_in` でemailとパスワードを入力することで認証できる.

1. `https://{取得したドメイン}/login/{current_user.id}` で左からApp key, App secretを入力して保存する.

1. `https://www.dropbox.com/oauth2/authorize/?client_id={App key}&response_type=code&token_access_type=offline` にアクセスしてアクセスコードをコピーする.このアクセスコードを`https://{取得したドメイン}/login/{current_user.id}`で入力してアクセストークンを発行する.


## http1,http2を使用したアップロード



## http3を使用した転送方法

## 分割アップロード