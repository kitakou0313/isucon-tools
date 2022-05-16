# isucon-tools
isuconで使うツール群をdockerで使えるようにまとめたtemplate

## 使用準備
- 本テンプレートを使ってリポジトリを作成します
- `make build`を実行します
    - ツールを実行するためのdocker imageがビルドされます
- 本番環境への接続情報（ホスト名|IPアドレス、`SSH`のポート番号）を`./hosts/hosts.txt`に記述します
    - 本リポジトリ内のスクリプトはこのファイル内の接続情報を用いて通信します
- 本番環境からwebアプリのコード、初期化用SQLファイルなどを取得し、`./webapp`内に追加します

## 使用可能なツール群

### 解析用ツール
dockerを用いて実行されるため、インストール不要で使用可能です。よく使う形式を`make`コマンド内でまとめていますが、直接`docker compose run...`で実行することで任意のオプションを使用できます。

- kataribe
    - https://github.com/matsuu/kataribe
    - nginxなどのwebサーバーのログから実行時間を解析
    - 実行時間を占めているエンドポイントの発見などに使用可能
- mysqlslowdump
    - MySQLのスローログを解析
    - 実行時間が長いクエリを発見できる
    - DBがボトルネックになっているケースで有効
        - indexが効いていない、テーブルの結合が遅いなど
- pprof
    - Golang用のパフォーマンス分析ツール
    - アプリケーション側の処理時間を解析できる
    - アプリケーションがボトルネックになっている場合に有効
        - htmlのtemplateに関する処理など

### デプロイ、ベンチ関連のツール
実行環境によって詳細なパス、管理したいファイルなどは異なると思うので、調整していただければと思います

- `bench/before-bench.sh`
    - ベンチ実行前に行う処理をまとめたスクリプト
        - 本番環境内のログのバックアップ、初期化
            - 前ベンチのログの混入を防ぐため
- `bench/after-bench.sh`
    - ベンチ完了後の処理をまとめたスクリプト
        - nginxの`access.log`, MySQLのスロークエリログ、`pprof`の出力ファイルの取得
- `deploy/deloy.sh`
    - 本番環境へのデプロイ用スクリプト
    - ビルドしたwebアプリケーションの実行ファイル+データベースの初期化用SQLファイルのデプロイ
        - 近年のisuconではベンチ開始時に`/initialize`エンドポイントにアクセス、データベースの再作成+データ投入+indexの作成が行われ、参加者はこの初期化用SQLファイルにインデックスの定義を記述するケースが多いため、同時にデプロイする形式にしています
- `deploy/sync-settings.sh`
    - 各種設定ファイルをリモートに送信
        - nginxの`nginx.conf`、MySQLの`my.cnf`
    - 大会形式によっては環境変数管理用の`.env`なども管理する必要がありそうなので良い感じに調整してください

## スクリプトのテストについて
- `docker-compose.yaml`内の`deploy-test`コンテナには`nginx`, `mysql`がインストールされており、`SSH`経由でアクセス可能になっています。デプロイなどに用いるスクリプトのテストに使用してください
- `deploy-test/id_rsa/`内に秘密鍵、公開鍵を作成することで公開鍵認証でアクセス可能です
    - ファイル名を`id_rsa`,`id_rsa.pub`とすることでgitignoreされます

## ToDo

## 参考にさせていただいたサイト
- https://qiita.com/y-vectorfield/items/587d3f3a6eec8f251f3c
- https://blog.yuuk.io/entry/web-operations-isucon