# 必要なパラメータを考える
# サービス名
# region
# deployオプション cpu, --noauthとか

resource "google_cloud_run_service" "audiy_api" {
  name     = local.service_name_api
  location = var.region

  template {
    spec {
      containers {
        image = "${local.image_fullname_api}:latest"

        env {
          name  = "GCS_INPUT_AUDIO_BUCKET"
          value = google_storage_bucket.audio.name
        }

        env {
          name  = "TOPIC_NAME"
          value = google_pubsub_topic.topic.name
        }

        env {
          name  = "SLACK_BOT_TOKEN"
          value = var.slack_bot_token
        }

        env {
          name  = "GOOGLE_CLIENT_ID"
          value = var.google_client_id
        }

        resources {
          limits = {
            "cpu" : "1000m",
            "memory" : "128Mi",
          }
        }

        //        dynamic "env" {
        //          for_each = merge(
        //            local.env,
        //          )
        //
        //          content {
        //            name  = env.key
        //            value = env.value
        //          }
        //        }
      }
      // 指定しないとデフォルトのサービスアカウントになってしまう
      service_account_name = google_service_account.adminapi.email


      timeout_seconds = 10
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  //      revisionごとのURL生成
  autogenerate_revision_name = true

  depends_on = [
    google_project_service.services["run.googleapis.com"],
    google_project_iam_member.adminapi-observability,
  ]

  lifecycle {
    ignore_changes = [
      template[0].spec[0].containers[0].image,
    ]
  }
}

output "run_api_urls" {
  value = google_cloud_run_service.audiy_api.status.0.url
}
