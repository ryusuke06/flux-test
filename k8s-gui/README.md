# Kubernetes Dashboard のデプロイメント

このディレクトリには、Kustomizeを使用してKubernetes Dashboardをデプロイするための設定ファイルが含まれています。

## 含まれるファイル

- `kustomization.yaml` - Kustomizeの設定ファイル
- `service-account.yaml` - 管理者用ServiceAccountとSecret
- `cluster-role-binding.yaml` - クラスター管理者権限のバインディング
- `get-token.sh` - 認証トークン取得用スクリプト

## デプロイ手順

1. **ダッシュボードのデプロイ**
   ```bash
   kubectl apply -k .
   ```

2. **デプロイ状況の確認**
   ```bash
   kubectl get all -n kubernetes-dashboard
   ```

3. **認証トークンの取得**
   ```bash
   ./get-token.sh
   ```

## アクセス方法

### 方法1: Port Forward（推奨）
```bash
kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard 8080:443
```
その後、https://localhost:8080 にアクセス

### 方法2: kubectl proxy経由
```bash
kubectl proxy
```
その後、以下のURLにアクセス：
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

## ログイン

1. ダッシュボードにアクセスすると、ログイン画面が表示されます
2. "Token" オプションを選択
3. `./get-token.sh` で取得したトークンを入力
4. "サインイン" をクリック

## 注意事項

- このServiceAccountはクラスター管理者権限を持っているため、本番環境では権限を適切に制限してください
- HTTPSアクセスが必要です（自己署名証明書の警告が表示される場合があります）
- 参考情報: [Kubernetes ダッシュボードとは？使い方を解説](https://sysdig.jp/learn-cloud-native/what-is-the-kubernetes-dashboard/)

## トラブルシューティング

### トークンが取得できない場合
```bash
kubectl get secret admin-user -n kubernetes-dashboard
kubectl describe secret admin-user -n kubernetes-dashboard
```

### Podが起動しない場合
```bash
kubectl get pods -n kubernetes-dashboard
kubectl describe pod <pod-name> -n kubernetes-dashboard
``` 
