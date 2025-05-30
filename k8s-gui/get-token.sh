#!/bin/bash

echo "Kubernetes Dashboard Admin User Token:"
echo "========================================"

# Secretからトークンを取得
TOKEN=$(kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath='{.data.token}' | base64 -d)

if [ -z "$TOKEN" ]; then
    echo "エラー: トークンが取得できませんでした。"
    echo "以下のコマンドでSecretが存在するか確認してください："
    echo "kubectl get secret admin-user -n kubernetes-dashboard"
    exit 1
fi

echo "$TOKEN"
echo ""
echo "使用方法："
echo "1. 上記のトークンをコピーしてください"
echo "2. ダッシュボードのログイン画面で 'Token' を選択"
echo "3. コピーしたトークンを貼り付けてサインイン"
echo ""
echo "ダッシュボードへのアクセス："
echo "kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard 8080:443"
echo "その後、 https://localhost:8080 にアクセス" 
