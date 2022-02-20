# go-boiler

Goのセットアップからデプロイまでのフローが確認できるレポジトリ🐸

# サービスアカウント作成

featureブランチをpushするとCIがビルドイメージを作成する
その際にサービスアカウントが必要なので先に作成する

最初の最初はローカルでterraform実行でよいのでは

# tfstateを保存するバケット作成する

GCSではなくてTerraformCloudを利用するならば、不要

% gsutil mb -p go-boiler-t1 -l asia-northeast1 -b on gs://go-boiler-t1-tf-state
Creating gs://go-boiler-t1-tf-state/...


やってない
↓
# APIの有効化

terraform apply -target=google_project_service.enable_api

# terraform実行ユーザの作成 
terraform apply -target=google_service_account.github_actions
terraform apply -target=google_project_iam_member.github_actions_default

terraform apply -target=google_iam_workload_identity_pool.github_pool
terraform apply -target=google_iam_workload_identity_pool_provider.github_provider
