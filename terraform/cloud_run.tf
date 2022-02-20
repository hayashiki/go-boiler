data "google_cloud_run_service" "default" {
  name     = var.name
  location = var.location
}

locals {
  current_image = data.google_cloud_run_service.default.template != null ? data.google_cloud_run_service.default.template.0.spec.0.containers.0.image : null
  new_image     = "gcr.io/${var.project}/go-boiler-api:${var.image_tag}"
  image         = (local.current_image != null && var.image_tag == "latest") ? local.current_image : local.new_image
}

resource "google_cloud_run_service" "default" {
  name     = var.name
  location = var.location

  template {
    spec {
      service_account_name = google_service_account.run_sa.email

      containers {
        image = local.image
#        image = "gcr.io/go-boiler-t1/go-boiler-api:latest"

        resources {
          limits = {
            cpu    = "1000m"
            memory = "128Mi"
          }
        }
      }
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = "1"
      }

      labels = {
        service = var.name
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  autogenerate_revision_name = true
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_service.default.location
  project  = google_cloud_run_service.default.project
  service  = google_cloud_run_service.default.name

  policy_data = data.google_iam_policy.noauth.policy_data
}

output "run_urls" {
  value = google_cloud_run_service.default.status.0.url
}
