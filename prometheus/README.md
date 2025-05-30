# Prometheus 監視スタック (Flux GitOps)

このPrometheusスタックは、FluxでGitOpsアプローチを使ってKubernetes環境に監視ソリューションを提供します。

## 🚀 クイックスタート

### 前提条件

- Kubernetes クラスター（v1.19+）
- Flux v2がインストール済み
- kubectl が設定済み

### Fluxでのデプロイ

```bash
# prometheusディレクトリをGitリポジトリに追加してコミット
git add prometheus/
git commit -m "Add Prometheus monitoring stack"
git push

# または、直接適用する場合
kubectl apply -k prometheus/
```

## 📊 含まれるコンポーネント

- **Prometheus** - メトリクス収集・保存
- **Grafana** - 可視化・ダッシュボード
- **AlertManager** - アラート管理
- **Node Exporter** - ノードメトリクス
- **kube-state-metrics** - Kubernetesメトリクス

## 🔧 Flux設定

### ファイル構成

```
prometheus/
├── namespace.yaml           # monitoring名前空間
├── helm-repository.yaml     # Prometheusコミュニティのリポジトリ
├── helm-release.yaml        # メインのデプロイメント設定
├── kustomization.yaml       # 適用順序の管理
└── README.md               # この文書
```

### 設定の更新

設定を変更する場合は、`helm-release.yaml` のvaluesセクションを編集してください。
Fluxが自動的に変更を検出してデプロイします。

### ストレージ設定

デフォルトでは以下のストレージが設定されています：

- Prometheus: 10Gi
- Grafana: 5Gi
- AlertManager: 2Gi

ストレージクラスは `standard` を使用しています。環境に応じて変更してください。

## 🔍 監視状況の確認

### Fluxの状態確認

```bash
# HelmReleaseの状態確認
flux get helmreleases -n monitoring

# HelmRepositoryの状態確認
flux get sources helm -n monitoring

# デプロイログの確認
flux logs --follow --namespace=monitoring
```

### アプリケーションアクセス

デプロイ後、以下のコマンドでアクセスできます：

```bash
# Prometheus UI
kubectl port-forward -n monitoring svc/prometheus-stack-kube-prom-prometheus 9090:9090
# http://localhost:9090 でアクセス

# Grafana UI
kubectl port-forward -n monitoring svc/prometheus-stack-grafana 3000:80
# http://localhost:3000 でアクセス
# ユーザー名: admin, パスワード: admin123

# AlertManager UI
kubectl port-forward -n monitoring svc/prometheus-stack-kube-prom-alertmanager 9093:9093
# http://localhost:9093 でアクセス
```

## 🛠️ カスタマイズ

### Ingress の有効化

外部からのアクセスを許可する場合は、`helm-release.yaml` の values で Ingress を有効化してください：

```yaml
values:
  prometheus:
    ingress:
      enabled: true
      hosts:
        - prometheus.your-domain.com
  grafana:
    ingress:
      enabled: true
      hosts:
        - grafana.your-domain.com
```

### アラート設定

AlertManager の設定は `helm-release.yaml` の `alertmanager.config` セクションで変更できます。

### 環境別設定

複数環境で異なる設定を使用する場合は、Fluxのオーバーレイ機能を使用してください：

```bash
# 本番環境用の設定ファイルを作成
mkdir -p environments/production
cat > environments/production/kustomization.yaml << EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../prometheus
patchesStrategicMerge:
  - production-values.yaml
EOF
```

## 🔍 トラブルシューティング

### Flux関連の問題

```bash
# HelmReleaseのイベント確認
kubectl describe helmrelease prometheus-stack -n monitoring

# HelmRepositoryの同期確認
kubectl describe helmrepository prometheus-community -n monitoring

# Fluxコントローラーのログ確認
kubectl logs -n flux-system deployment/helm-controller
kubectl logs -n flux-system deployment/source-controller
```

### 一般的な問題

1. **HelmRepository同期エラー**: ネットワーク接続を確認
2. **PVC作成エラー**: ストレージクラスが利用可能であることを確認
3. **リソース不足**: ノードのリソースを確認

### 完全リセット

```bash
# HelmReleaseを削除
flux delete helmrelease prometheus-stack -n monitoring

# 名前空間ごと削除
kubectl delete namespace monitoring
```

## 📚 参考資料

- [Flux Documentation](https://fluxcd.io/docs/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [kube-prometheus-stack Chart](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) 
