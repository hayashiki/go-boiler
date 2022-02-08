resource "google_project_service" "enable_api" {
  for_each = toset([
    "iam.googleapis.com",
  ])
  project = var.project
  service = each.value

  disable_dependent_services = true
}
