# Prometheus 監視スタック (Kustomize)

このPrometheusスタックは、純粋なKubernetesマニフェストとKustomizeを使って監視ソリューションを提供します。

## 🚀 クイックスタート

### 前提条件

- Kubernetes クラスター（v1.19+）
- kubectl が設定済み

### Kustomizeでのデプロイ

```bash
# prometheusディレクトリをGitリポジトリに追加してコミット
git add prometheus/
git commit -m "Add Prometheus monitoring stack with Kustomize"
git push

# または、直接適用する場合
kubectl apply -k prometheus/
```

## 📊 含まれるコンポーネント

- **Prometheus** - メトリクス収集・保存
- **Grafana** - 可視化・ダッシュボード
- **RBAC** - 適切な権限設定
- **ServiceAccount** - セキュアなアクセス

## 🔧 Kustomize構成

### ディレクトリ構成

```
prometheus/
├── base/                           # ベース設定
│   ├── namespace.yaml              # monitoring名前空間
│   ├── rbac.yaml                   # ServiceAccount, ClusterRole, Binding
│   ├── prometheus-config.yaml      # Prometheus設定ConfigMap
│   ├── prometheus-deployment.yaml  # Prometheusデプロイメント・PVC・Service
│   ├── grafana.yaml                # Grafanaデプロイメント・PVC・Service
│   └── kustomization.yaml          # ベース層のリソース管理
├── kustomization.yaml              # メインのKustomize設定
└── README.md                       # この文書
```

### 設定のカスタマイズ

設定を変更する場合は、以下のアプローチを使用してください：

1. **overlays** ディレクトリで環境別設定
2. **patches** を使った部分的な変更
3. **configMapGenerator** で設定ファイルの生成

### ストレージ設定

デフォルトでは以下のストレージが設定されています：

- Prometheus: 10Gi
- Grafana: 5Gi

ストレージクラスは `default` を使用しています。

## 🔍 監視状況の確認

### デプロイ状況の確認

```bash
# 全リソースの確認
kubectl get all -n monitoring

# Podの状態確認
kubectl get pods -n monitoring

# ストレージの確認
kubectl get pvc -n monitoring

# サービスの確認
kubectl get svc -n monitoring
```

### アプリケーションアクセス

デプロイ後、以下のコマンドでアクセスできます：

```bash
# Prometheus UI
kubectl port-forward -n monitoring svc/prometheus 9090:9090
# http://localhost:9090 でアクセス

# Grafana UI
kubectl port-forward -n monitoring svc/grafana 3000:3000
# http://localhost:3000 でアクセス
# ユーザー名: admin, パスワード: admin123
```

## 🛠️ カスタマイズ

### 環境別設定

複数環境で異なる設定を使用する場合は、overlaysを作成してください：

```bash
# 本番環境用のオーバーレイ作成
mkdir -p prometheus/overlays/production
cat > prometheus/overlays/production/kustomization.yaml << EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: monitoring

resources:
  - ../../base

patchesStrategicMerge:
  - prometheus-resources.yaml

images:
  - name: prom/prometheus
    newTag: v2.45.0
  - name: grafana/grafana
    newTag: 10.1.0
EOF
```

### リソース制限の変更

本番環境でリソース制限を変更する場合：

```yaml
# overlays/production/prometheus-resources.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
spec:
  template:
    spec:
      containers:
      - name: prometheus
        resources:
          limits:
            cpu: 2000m
            memory: 4Gi
          requests:
            cpu: 1000m
            memory: 2Gi
```

### 追加の監視対象

新しいアプリケーションを監視対象に追加する場合：

1. アプリケーションにメトリクスエンドポイントを追加
2. アノテーションを付与：
   ```yaml
   metadata:
     annotations:
       prometheus.io/scrape: "true"
       prometheus.io/port: "8080"
       prometheus.io/path: "/metrics"
   ```

## 🔍 トラブルシューティング

### 一般的な問題

```bash
# Podのログ確認
kubectl logs -n monitoring deployment/prometheus
kubectl logs -n monitoring deployment/grafana

# イベントの確認
kubectl get events -n monitoring --sort-by='.lastTimestamp'

# リソースの詳細確認
kubectl describe pod -n monitoring -l app=prometheus
kubectl describe pvc -n monitoring
```

### よくある問題と解決法

1. **PVC作成エラー**: 
   ```bash
   kubectl get storageclass
   # ストレージクラスが利用可能であることを確認
   ```

2. **RBAC権限エラー**:
   ```bash
   kubectl get clusterrolebinding prometheus
   # ClusterRoleBindingが正しく作成されているか確認
   ```

3. **設定の問題**:
   ```bash
   kubectl get configmap -n monitoring prometheus-config -o yaml
   # ConfigMapの内容を確認
   ```

### 完全リセット

```bash
# 全て削除
kubectl delete -k prometheus/

# 名前空間の強制削除（必要に応じて）
kubectl delete namespace monitoring --force --grace-period=0
```

## 📚 参考資料

- [Kustomize Documentation](https://kustomize.io/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Kubernetes Monitoring](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-usage-monitoring/)
