# 実験手順方法

## デバイス側の準備
---

デバイス側では疑似的にモバイルのネットワーク帯域に制限する必要がある.
よって，下記のコマンドで実行した.
```
  sudo dnctl pipe 1 config bw 60Mbps
  sudo dnctl pipe 2 config bw 15Mbps 
```
次に，下記の文字列を`/etc/pf.conf` に追加する.
```

  dummynet in quick proto udp all pipe 1
  dummynet out quick proto udp all pipe 2
  dummynet in quick proto tcp all pipe 1 
  dummynet out quick proto tcp all pipe 2
```
最後に設定を反映さて有効化する.

```
  sudo pfctl -f /etc/pf.conf
  sudo pfctl -e
```
無効化したい場合は `sudo pfctl -d` を実行する
転送するファイルに関しては `mkfile` コマンドを使用してファイルを作成する.


## MECサーバーの準備
---
dockerで環境を構築しているので下記のコマンドで対象のサーバーで構築できる.
構成は，rails，mysql，nginxとなっている.
quicheは，QUICプロトコルを使用するためにcloneしている.
```
cd mec_uploads_cache
git clone https://github.com/cloudflare/quiche.git
docker compose up --build
```
また，初めて環境を構築した際は下記のコマンドを実行してDBを作成する．
```
docker-compose exec web rails db:create
docker-compose exec web rails db:migrate
```
ただし，https化を行うためdockerを起動する前に証明書とドメインを取得してください.

## 転送するクラウドの準備
---
本実験ではDropboxを使用した.
よってDropboxの設定を説明する.

1. Dropboxでアクセスし，アプリケーションを作成する.
1. Dropboxの権限を変更し，files.content.write，files.content.read，files.metadata.readを許可する
1. App key，App secretを控えておく
  
一旦Dropbox側の設定が完了した.

## MECを経由するアップロードするための準備

1. ユーザ登録を行う. `https://{取得したドメイン}/users/sign_up` でemailとパスワードを設定する.
次回以降のログインは`https://{取得したドメイン}/users/sign_in` でemailとパスワードを入力することで認証できる.

2. `https://{取得したドメイン}/login/{current_user.id}` で左からApp key，App secretを入力して保存する.

3. `https://www.dropbox.com/oauth2/authorize/?client_id={App key}&response_type=code&token_access_type=offline` にアクセスしてアクセスコードをコピーする.このアクセスコードを`https://{取得したドメイン}/login/{current_user.id}`で入力してアクセストークンを発行する.
   
4. コマンドラインでログインしたい場合は `sign_in.sh` を実行する.

## 直接アップロード
---
https://github.com/andreafabrizi/Dropbox-Uploader を使用してアップロードする.
トークンの登録やアップロード方法はDropbox-UploaderのREADMEを参照して転送する.
時間を計測する際はtimeコマンドを先頭につけて計測する.

```
time ./dropbox_uploader.sh upload "./1g_dummy.txt" "/1g_dummy.txt"
```

## http1，http2を使用したアップロード
---
curlコマンドを使用して実行する．
```
time curl -b cookie.txt --request POST 'https://{www.shinya-tan.de}/posts' -F "file=@./1g_dummy.txt"
time curl -b cookie.txt --request POST 'https://{www.shinya-tan.de}/posts' -F "file=@./1g_dummy.txt" --http2

```
中括弧の中には取得したドメインを入れる．

## http3を使用した転送方法
---
- Google ChromeのQUICを有効化する
- `https://{取得したドメイン}/posts/new` の画面をGoogle Chromeで開く
- 複数回リロードしてQUICで通信ができていることをデベロッパーモードで確認する.(QUICが行われているかどうか判断する拡張を入れるとわかりやすい)
- 上記の状態でファイルを転送し，デベロッパーモードでレスポンス時間を計測する.


## 分割アップロード

- 対象のファイルを用意する
- 下記のコマンドを実行する．この時`xargs.sh`にある変数を適宜変更する.
- ```
   time ./xargs.sh
  ```