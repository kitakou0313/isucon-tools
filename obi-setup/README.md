# OBI (OpenTelemetry eBPF Instrumentation) セットアップ手順

参照: https://opentelemetry.io/docs/zero-code/obi/

## セットアップ

- `obi-setup/`一式(`docker-compose.yaml`, `config.yaml`)を対象サーバーに配置します
- `config.yaml`内の`open_port`を対象webappの待受ポートに変更します
    - OTLPでの送信先がある場合は`otel_traces_export.endpoint`, `otel_metrics_export.endpoint`等のコメントを解除して設定します
- 以下のコマンドでOBIを起動します
    - `docker compose up -d`
- 以下のコマンドで動作確認を行います
    - `docker compose logs -f obi`
        - `config.yaml`の`trace_printer: text`により、計装されたトレースが標準出力に出力されます
    - Prometheusエクスポートを有効化した場合
        - `curl localhost:${prometheus_exportのport}/metrics`
- `config.yaml`を変更した場合、以下のコマンドで再起動し設定を反映します
    - `docker compose restart obi`
- 停止する場合は以下のコマンドを実行します
    - `docker compose down`
