# Go コンパイル時インストルメンテーション導入手順

参照: https://opentelemetry.io/ja/docs/zero-code/go/compile-time/

## 概要

`otelc` は通常の `go build` をラップするツールです。ビルド時に以下を行います。

1. Goツールチェーンの `-toolexec` メカニズムを使い、各パッケージのコンパイルをフックする
2. インストルメンテーションルールに基づき、パッケージ・関数をマッチングする
3. マッチした箇所にフックポイントを注入し、OpenTelemetryの計装コードにリンクする

インストルメンテーションはコンパイル時にバイナリへ埋め込まれるため、依存している(自分で変更できない)サードパーティライブラリの内部も計装対象にでき、実行時にエージェントをアタッチする手順も不要になります。

- `obi-setup/`（eBPFベースのzero-code instrumentation、OBI）との使い分け
    - ビルドパイプラインは変更できるがソースコードは変更したくない場合
    - サードパーティライブラリの内部まで計装したい場合
    - （OBIのような）特権エージェントを対象サーバー上で実行できない場合
    - 上記に該当する場合は本手順（compile-time instrumentation）が適しています

## 前提条件

- [Go](https://go.dev/) 1.25以上
- 対象のGoアプリケーションが `./webapp` 配下に配置されていること
    - ルートの`README.md`記載の手順（`scp -rv ${HOST1_SSH_USER}@${HOST1}:/home/isucon/webapp/* ./webapp`）で本番環境から取得

## otelcのインストール

```sh
go install go.opentelemetry.io/otelc/tool/cmd/otelc@latest
```

`$(go env GOPATH)/bin` に `otelc` バイナリが配置されます。以降の手順は `otelc` が `PATH` に通っている前提です。

## アプリケーションの計装

対象アプリケーションのモジュールディレクトリ（`webapp`配下、`go.mod`のある場所）で以下を実行します。

### 基本: `go build` を `otelc go build` に置き換える

```sh
otelc go build -o myapp .
```

`go` 以降の引数はそのままGoツールチェーンに渡されるため、通常のビルドオプションはそのまま使用できます。デフォルトで対応ライブラリ（[対応ライブラリ一覧](#対応ライブラリ一覧)参照）を自動検出し、設定・コード変更なしに計装します。

### ビルドコマンドを変更したくない場合

既存のビルドシステムやスクリプトで `go build` コマンドが固定されている場合は、`otelc setup` を一度実行した上で `GOFLAGS` 経由で `-toolexec` を指定し、通常通り `go build` を実行します。

```sh
otelc setup
export GOFLAGS="${GOFLAGS} '-toolexec=otelc toolexec'"
go build -o myapp .
```

## 実行時のテレメトリ設定

計装済みアプリケーションは標準のOpenTelemetry環境変数で設定します。例えば`obi-setup/`の`otel-collector`宛にOTLPで送信する場合は以下の通りです。

```sh
export OTEL_SERVICE_NAME=myapp
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
./myapp
```

環境変数の全リストは[設定](#設定)を参照してください。

## 対応ライブラリ一覧

以下のライブラリ・フレームワークを依存関係が使用している場合、対応するインストルメンテーションがビルド時に自動的に注入されます。

| ライブラリ・フレームワーク | インポートパス | 計装対象の操作 |
| --- | --- | --- |
| HTTP（標準ライブラリ） | `net/http` | クライアント/サーバーリクエスト |
| gRPC | `google.golang.org/grpc` | クライアント/サーバー呼び出し |
| SQLデータベース | `database/sql` | データベース呼び出し |
| Gin | `github.com/gin-gonic/gin` | サーバーリクエスト |
| Redis | `github.com/redis/go-redis/v9` | クライアントコマンド |
| MongoDB | `go.mongodb.org/mongo-driver/mongo` | クライアントコマンド |
| Kafka | `github.com/segmentio/kafka-go` | メッセージの送受信 |
| OpenAI | `github.com/openai/openai-go`（v1〜v3） | クライアント呼び出し |
| Anthropic | `github.com/anthropics/anthropic-sdk-go` | クライアント呼び出し |
| Kubernetesクライアント | `k8s.io/client-go/tools/cache` | Informerキャッシュ操作 |
| slog（標準ライブラリ） | `log/slog` | ログレコード |
| Logrus | `github.com/sirupsen/logrus` | ログレコード |

- HTTP/gRPCの計装はspanとmetricsを生成し、サービス間のcontext propagationも自動で行われます
- 各ライブラリの[semantic conventions](https://opentelemetry.io/docs/specs/semconv/)に従います
- Goランタイムメトリクスはデフォルトで収集されます。無効化する場合は `OTEL_GO_DISABLED_INSTRUMENTATIONS` に `runtimemetrics` を追加してください
- 対応バージョンの正確な情報は[instrumentation packages](https://github.com/open-telemetry/opentelemetry-go-compile-instrumentation/tree/main/instrumentation)を参照
- 未対応のライブラリがある場合は[feature request](https://github.com/open-telemetry/opentelemetry-go-compile-instrumentation/issues)を作成するか、[instrumentation guide](https://github.com/open-telemetry/opentelemetry-go-compile-instrumentation/blob/main/docs/instrument-guide.md)に従って自作できます

## 設定

### otelcコマンド

| コマンド | 用途 |
| --- | --- |
| `otelc go …` | `go`コマンド（`go build`など）を計装ありで実行 |
| `otelc setup` | 計装用の環境をセットアップ |
| `otelc pin` | 現在のモジュール向けに計装パッケージを固定する`otel.instrumentation.go`を生成・更新 |
| `otelc cleanup` | setup/buildフェーズで作成された成果物を削除 |
| `otelc version` | ツールのバージョンを表示 |

フラグはサブコマンドの前に指定します。

| フラグ | 環境変数 | 用途 |
| --- | --- | --- |
| `--rules <file>` | - | カスタムインストルメンテーションルールファイルを使用 |
| `--debug`, `-d` | `OTELC_DEBUG=1` | ビルドのデバッグログを有効化 |
| `--work-dir`, `-w` | `OTELC_WORK_DIR` | ビルド中に生成される作業ファイルの出力先ディレクトリ |

```sh
otelc --rules my-rules.yaml --debug go build -o myapp .
```

### ランタイム環境変数

標準のOpenTelemetry SDK環境変数（exporter、resource、サービス識別情報）が使用できます。

- `OTEL_SERVICE_NAME`: テレメトリに付与されるサービス名
- `OTEL_EXPORTER_OTLP_ENDPOINT`: 送信先のOTLPエンドポイント
- `OTEL_RESOURCE_ATTRIBUTES`: 追加のresource attributes

加えて、注入されたどのインストルメンテーションを実行時に有効化するかを以下で制御できます。

| 変数 | 用途 |
| --- | --- |
| `OTEL_GO_ENABLED_INSTRUMENTATIONS` | 有効化するインストルメンテーションのカンマ区切りリスト（例: `nethttp,grpc`）。指定した場合、リストにあるもののみ有効になる |
| `OTEL_GO_DISABLED_INSTRUMENTATIONS` | 無効化するインストルメンテーションのカンマ区切りリスト |

### カスタムインストルメンテーションルール

どのコードを計装対象にするかは宣言的なYAMLルールで制御されます。ルールは対象パッケージを指定し、セレクタで絞り込み、何を注入するかを宣言します。

```yaml
instrument_sql_exec:
  target: database/sql
  where:
    func: Exec
    recv: '*DB'
  do:
    - inject_hooks:
        before: BeforeExec
        after: AfterExec
        path: github.com/example/sqlinstr
```

`--rules` でカスタムルールファイルをビルドに渡せます。また、Goパッケージ内に`otel.instrumentation.go`（または`otelc.tool.go`）ファイルを置き、`otelc.yml`や`*.otelc.yml`でルールを提供することで、ツールが自動的に発見・ロードする形式もサポートされています。ルールスキーマの詳細は[instrumentation rules documentation](https://github.com/open-telemetry/opentelemetry-go-compile-instrumentation/blob/main/docs/rules.md)を参照してください。

## トラブルシューティング

### デバッグログの有効化

```sh
otelc --debug go build -o myapp .
```

デバッグ出力（`debug.log`を含む）はツールの作業ディレクトリ（デフォルトはモジュール内の`.otelc-build`）に出力されます。どのルールがマッチし、何が注入されたかを確認できます。

### テレメトリが出力されない場合

1. バイナリが`otelc`経由でビルドされているか（通常の`go build`ではないか）確認する
2. アプリケーションが[対応ライブラリ](#対応ライブラリ一覧)を実際に使用しており、依存しているバージョンがインストルメンテーションルールの対応範囲内か確認する
3. exporterの設定を確認する。`OTEL_EXPORTER_OTLP_ENDPOINT`が未設定・誤りだとテレメトリの送信先がない。`OTEL_LOG_LEVEL=debug`でエクスポートエラーを表面化できる
4. `OTEL_GO_ENABLED_INSTRUMENTATIONS` / `OTEL_GO_DISABLED_INSTRUMENTATIONS` で対象のインストルメンテーションが無効化されていないか確認する

### ビルド成果物のクリーンアップ

ビルドの挙動がおかしい場合は、以前のsetup/buildフェーズで作成された成果物を削除してからビルドし直します。

```sh
otelc cleanup
```