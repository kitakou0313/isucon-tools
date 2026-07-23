# OBI (OpenTelemetry eBPF Instrumentation) セットアップ手順

参照: https://opentelemetry.io/docs/zero-code/obi/

## 構成

```
obi-setup/
├── docker-compose.yaml         # obi, otel-collector の compose 定義
├── obi-container/
│   └── config.yaml             # OBI の設定ファイル
└── otel-col-on-host/
    └── otel-collector.yaml     # ホスト上で稼働する OTel Collector の設定ファイル
```

- `obi`: 対象webappへの計装を行うコンテナ
- `otel-collector`: `obi`からのテレメトリ受信、およびホストのメトリクス(cpu/memory/disk/network)収集を行うコンテナ

## セットアップ

- `obi-setup/`一式(`docker-compose.yaml`, `obi-container/`, `otel-col-on-host/`)を対象サーバーに配置します
- `obi-container/config.yaml`内の`open_port`を対象webappの待受ポートに変更します
    - `otel_traces_export.endpoint`, `otel_metrics_export.endpoint`はデフォルトでローカルの`otel-collector`コンテナ(`http://localhost:4317`)宛に設定済みです
- `otel-col-on-host/otel-collector.yaml`内の`exporters.otlp.endpoint`(`{target hostname}:{target port}`)を実際の送信先に変更します
- 以下のコマンドでOBIとOTel Collectorを起動します
    - `docker compose up -d`
- 以下のコマンドで動作確認を行います
    - `docker compose logs -f obi`
        - `config.yaml`の`trace_printer: text`により、計装されたトレースが標準出力に出力されます
    - `docker compose logs -f otel-collector`
        - OTel Collector側の受信・転送状況を確認できます
    - Prometheusエクスポートを有効化した場合
        - `curl localhost:${prometheus_exportのport}/metrics`
- 設定ファイルを変更した場合、以下のコマンドで再起動し設定を反映します
    - `docker compose restart obi`
    - `docker compose restart otel-collector`
- 停止する場合は以下のコマンドを実行します
    - `docker compose down`
