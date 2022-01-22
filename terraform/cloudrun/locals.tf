locals {
  project_id     = "bulbopencensus"
  project_number = "185245971175"
  region         = "us-central1"

  api_name           = "dog"
  image_name_api     = local.api_name
  image_fullname_api = "gcr.io/${local.project_id}/${local.image_name_api}"

  steps = [
    {
      name = "gcr.io/cloud-builders/docker"
      args = ["build", "-t", local.image_fullname_api, "."]
    },
    {
      name = "gcr.io/cloud-builders/docker"
      args = ["push", local.image_fullname_api]
    },
    {
      name = "gcr.io/cloud-builders/gcloud"
      args = ["run", "deploy", "google_cloud_run_service.service.name", "--image", local.image_fullname_api, "--region", local.region, "--platform", "managed", "-q"]
    }
  ]
}

