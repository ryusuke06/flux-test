# HAProxy TCP Forwarder for RDP

このプロジェクトは、KubernetesでHAProxyを使用してRDP（リモートデスクトップ）接続のTCPフォワードを行うための設定です。

## セットアップ手順

### 1. RDPターゲットホストの設定

`configmap.yaml`の`TARGET_RDP_HOST`を実際のRDPサーバーのIPアドレスまたはホスト名に変更してください：

```yaml
server rdp_server1 192.168.1.100:3389 check
```

### 2. デプロイ

```bash
# Kustomizeを使用してデプロイ（推奨）
kubectl apply -k haproxy/

# または個別にデプロイ
kubectl apply -f haproxy/namespace.yaml
kubectl apply -f haproxy/configmap.yaml
kubectl apply -f haproxy/deployment.yaml
kubectl apply -f haproxy/service.yaml
```

### 3. ポートフォワードの設定

HAProxyサービスに接続：

```bash
# RDP用のポートフォワード
kubectl port-forward -n haproxy service/haproxy-service 3389:3389

# 統計情報確認用（オプション）
kubectl port-forward -n haproxy service/haproxy-service 8404:8404
```

### 4. RDP接続

ローカルマシンからRDPクライアントを使用して`localhost:3389`に接続してください。

## 設定の詳細

- **Namespace**: `haproxy`
- **ポート 3389**: RDP用のTCPフォワード
- **ポート 8080**: ヘルスチェック用（Kubernetesのリブネス/レディネスプローブ）
- **ポート 8404**: HAProxy統計情報（オプション）

## 確認コマンド

```bash
# Namespace の確認
kubectl get ns haproxy

# Pod の状態確認
kubectl get pods -n haproxy -l app=haproxy

# サービスの状態確認
kubectl get services -n haproxy haproxy-service

# ログの確認
kubectl logs -n haproxy -l app=haproxy

# 統計情報の確認（ポートフォワード後）
curl http://localhost:8404/stats
```

## トラブルシューティング

1. **接続できない場合**：
   - HAProxy Podが正常に動作しているか確認
   - ターゲットRDPサーバーにネットワーク接続できるか確認
   - ファイアウォール設定を確認

2. **設定変更後**：
   ```bash
   # ConfigMapを更新後、Podを再起動
   kubectl rollout restart deployment/haproxy -n haproxy
   ```

3. **複数のRDPサーバーを追加する場合**：
   `configmap.yaml`のbackend設定に追加のサーバーを記述してください：
   ```
   server rdp_server1 192.168.1.100:3389 check
   server rdp_server2 192.168.1.101:3389 check
   ```

## クリーンアップ

```bash
# 全てのリソースを削除
kubectl delete -k haproxy/

# または namespace ごと削除
kubectl delete namespace haproxy
```
