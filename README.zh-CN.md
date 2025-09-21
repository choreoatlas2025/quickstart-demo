# ChoreoAtlas CLI 快速上手演示（中文）

以契约即代码治理跨服务编排：发现（Discover）→ 规范（Specify）→ 引导（Guide）。

本仓库提供 2–10 分钟的上手体验，示例基于 Sock Shop 微服务。内容已与当前社区版（CE）CLI 对齐。

English? See README.md

## 前置条件
- Docker 与 Docker Compose
- Make（GNU Make）
- ChoreoAtlas CLI（或直接使用 Docker 镜像）

## 安装 CLI（任选其一）
```bash
# 方式一：Docker（无需本地安装）
alias choreoatlas='docker run --rm -v $(pwd):/workspace choreoatlas/cli:latest'

# 方式二：Homebrew（macOS/Linux）
brew tap choreoatlas2025/tap
brew install choreoatlas

# 方式三：下载二进制
# https://github.com/choreoatlas2025/cli/releases
```

## 一键体验
```bash
make demo
```
它会：
1) 发现：从示例 trace 生成 FlowSpec + ServiceSpec 契约
2) 校验：将编排与执行 trace 进行对照验证
3) 报告：生成并打开 HTML 报告

## 目录结构
```
.
├── docker-compose.yml          # （可选）简化版 Sock Shop 服务编排
├── Makefile                    # 一键化自动化脚本
├── traces/                     # 预置 trace
│   ├── successful-order.trace.json  # 内部格式（CE）- 正常路径
│   ├── failed-payment.trace.json    # 内部格式（CE）- 失败路径
│   ├── successful-order.json        # Jaeger 风格样例（参考）
│   └── failed-payment.json          # Jaeger 风格样例（参考）
├── contracts/                  # 生成或模板化的契约
│   ├── services/               # ServiceSpec（*.servicespec.yaml）
│   └── flows/                  # FlowSpec（顺序式 + 图/DAG）
│       ├── order-flow.flowspec.yaml         # 顺序式（legacy）
│       └── order-flow.graph.flowspec.yaml   # 图/DAG（推荐）
├── reports/                    # 生成的报告
└── scripts/                    # 演示脚本
```

## 多种演示路径
- 离线演示（2 分钟）：`make offline-demo`
- 在线演示（约 10 分钟）：`make live-demo`
- CI 集成演示：`make ci-demo`

## 分步操作
### 1) 根据 trace 发现契约
```bash
choreoatlas discover \
  --trace traces/successful-order.trace.json \
  --out contracts/flows/order-flow.flowspec.yaml \
  --out-services contracts/services
```

### 2) 校验编排并生成报告
```bash
# HTML 报告
choreoatlas validate \
  --flow contracts/flows/order-flow.graph.flowspec.yaml \
  --trace traces/successful-order.trace.json \
  --report-format html --report-out reports/validation-report.html

# 可选：JSON 报告
choreoatlas validate \
  --flow contracts/flows/order-flow.graph.flowspec.yaml \
  --trace traces/successful-order.trace.json \
  --report-format json --report-out reports/validation-report.json
```

### 3) 失败场景分析
```bash
choreoatlas validate \
  --flow contracts/flows/order-flow.graph.flowspec.yaml \
  --trace traces/failed-payment.trace.json \
  --report-format html --report-out reports/failure-analysis.html
```

提示：仓库已内置 GitHub Actions 工作流（.github/workflows/choreoatlas-validation.yml），直接启用即可在 CI 中生成 JUnit/HTML 报告工件。

注意：演示默认不自动打开浏览器，请到 `reports/` 目录手动查看报告（例如 `reports/validation-report.html` 或 `reports/successful-order-report.html`）。

## Trace 转换（Jaeger/OTLP → CE 内部格式）

如果你的追踪数据来自 Jaeger 或 OTLP，可用仓库内的小工具转换为 CE 可直接使用的内部格式：

```bash
# Jaeger -> CE 内部格式
make convert-trace IN=traces/successful-order.json OUT=traces/successful-order.trace.json MAP=demo

# OTLP -> CE 内部格式
make convert-trace IN=traces/otlp-sample.json OUT=traces/otlp-sample.trace.json

# 也可直接调用 Python 脚本
python3 scripts/convert-trace.py traces/successful-order.json \
  -o traces/successful-order.trace.json --map demo

# 然后执行校验
choreoatlas validate --flow contracts/flows/order-flow.graph.flowspec.yaml \
  --trace traces/successful-order.trace.json \
  --report-format html --report-out reports/from-converted.html
```

说明：
- 转换器支持两种输入：Jaeger 风格 JSON（spans[].operationName）与 OTLP JSON（resourceSpans[]...）。
- 操作名可能与 ServiceSpec 的 operationId 不一致，可用 `--map demo`（内置 Sock Shop 映射）或 `--map-file` 自定义映射文件。
- 真实 trace 往往没有完整响应载荷（response.body），相关校验可能 SKIP/FAIL；基于状态码的校验依旧有效。

## CI 集成（GitHub Actions 示例）
```yaml
name: ChoreoAtlas Validate
on: [push, pull_request]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup alias (Docker)
        run: echo "alias choreoatlas='docker run --rm -v $(pwd):/workspace choreoatlas/cli:latest'" >> $BASH_ENV
      - name: CI gate（lint + validate）
        run: |
          source $BASH_ENV
          choreoatlas ci-gate \
            --flow contracts/flows/order-flow.flowspec.yaml \
            --trace traces/successful-order.trace.json
      - name: Reports
        run: |
          source $BASH_ENV
          choreoatlas validate \
            --flow contracts/flows/order-flow.flowspec.yaml \
            --trace traces/successful-order.trace.json \
            --report-format junit --report-out reports/junit.xml
          choreoatlas validate \
            --flow contracts/flows/order-flow.flowspec.yaml \
            --trace traces/successful-order.trace.json \
            --report-format html --report-out reports/report.html
      - uses: actions/upload-artifact@v4
        with:
          name: choreoatlas-reports
          path: reports/
```

## 小贴士
- 推荐将 `alias ca=choreoatlas`，提升日常操作效率。
- FlowSpec 支持顺序式 `flow:` 与 DAG `graph:` 两种格式；建议使用 `graph:`，本示例保留 `flow:` 兼容。
- CE 完全离线、零遥测；trace 使用内部 JSON 结构（本仓库已提供样例）。

—— ChoreoAtlas CLI：以契约即代码映射、校验并引导你的服务编排
