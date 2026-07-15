# GolangアプリケーションのOTelでの自動軽装

## 方針
以下の二つがある

- compile time
    - OTel公式のものとAlibabaの2種がある
        - https://github.com/alibaba/loongsuite-go
        - https://github.com/open-telemetry/opentelemetry-go-compile-instrumentation
- eBPF
    - OBI(OpenTelemetry eBPF Instrumentation)と呼ばれるもの
        - https://opentelemetry.io/docs/zero-code/obi/
    - https://opentelemetry.io/docs/zero-code/go/autosdk/ はこれと手動計装したSpanを連携するためのSDK

## 資料
- https://docs.base14.io/blog/ebpf-instrumentation-go/