# 参考になりそうなやつ
## ORマッパーとかその辺
https://qiita.com/sazumy/items/726e7097c6ca4a9ca6e3
https://qiita.com/itkrt2y/items/32ad1512fce1bf90c20b
- Ruby On RailsのActiveRecordなどの一部のORマッパーはこのポリモーフィック関連をサポートしている
https://spice-factory.co.jp/development/has-and-belongs-to-many-table/

# https-portal
暫定的なhttps対応のため入れている。
ssl証明ができたら破棄したい。

# rails
## db設定
config/database.yml
productionについては現在未設定。
## seed
- masterのseed
`rails r db/seeds/master.rb`
- test用seed
`rails r db/seeds/test.rb`

# docker
## 起動まで(本番環境)
`docker compose build`
`docker compose up -d`
## 起動まで(local環境)
`docker compose -f docker-compose-local.yml build`
`docker compose -f docker-compose-local.yml up -d`

# env
ディレクトリ直下にある`.env`で種々の環境変数を管理。
`.env_example`を元にしたいので、環境変数を追加した場合はexampleにも追記をお忘れなく。
※ どうやら、読み込みは起動時に行なっているようなので変更したら再起動が必要かも。

# tips
## ルーティング
https://railsguides.jp/routing.html#コードからパスやurlを生成する
## 関連付け
https://qiita.com/ta1m1kam/items/d6a2b5e4611eb4d8e13a
## tailwindcss
### watch
以下コマンド打って、watchしといた方が開発スムーズかも。
`rails tailwindcss:watch`
以下ファイルが更新される模様。
`app/assets/builds/tailwind.css`
### config
以下に記載のパスが正しいか確認必要。
`config/tailwind.config.js`
stylesheet_link_tagに、'tailwind'入れるのが大事だった。
## preline
tabsとか、追加必要な時は以下を実施。
`npm i @preline/tabs`
`rails tailwindcss:build`
## cocoon
https://rutikkpatel.medium.com/cocoon-gem-in-ruby-on-rails-7-784b00e06bc2
## node_moduleの追加
以下の方法で、少なくともjsは追加できる模様。
- node_moduleを`npm i`でインストール。
- importmap.rbにて、紐付けしたい名前で./node_modules/配下の対象ファイルを指定。
- manifest.jsにて、`//= link 紐付け名`を追加。
- 使用したいところあるいはapplication.html.erbにて`javascript_include_tag(紐付け名)`を追加。
## no such file or directoryと出て起動しない
ファイルのCRLF系の問題かもしれません。
参考：https://kakiblo.com/docker-windows/

# 参考
## 環境構築
https://musclecoding.com/rails7-mysql8-docker/
https://qiita.com/neet244/items/8c5ed68fdc28121eecd7
## ログイン実装
https://qiita.com/d0ne1s/items/7c4d2be3f53e34a9dec7
