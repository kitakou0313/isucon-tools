# GolangアプリケーションのOTelでの自動軽装

## 方針
以下の二つがある

- compile time
- eBPF
    - OBI(OpenTelemetry eBPF Instrumentation)と呼ばれるもの
        - https://opentelemetry.io/docs/zero-code/obi/
    - https://opentelemetry.io/docs/zero-code/go/autosdk/ はこれと手動計装したSpanを連携するためのSDK