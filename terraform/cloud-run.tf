data "google_cloud_run_service" "default" {
  name     = var.name
  location = var.location
}

locals {
  current_image = data.google_cloud_run_service.default.template != null ? data.google_cloud_run_service.default.template[0].spec[0].containers[0].image : null
  new_image     = "gcr.io/go-boiler/go-boiler-api:${var.image_tag}"
  image         = (local.current_image != null && var.image_tag == "latest") ? local.current_image : local.new_image
}

resource "google_cloud_run_service" "default" {
  name     = var.name
  location = var.location

  template {
    spec {
#      service_account_name = var.service_account

      containers {
        image = local.image

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
