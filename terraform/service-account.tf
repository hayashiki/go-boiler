# For gke pod
resource "google_service_account" "github_actions" {
  project      = var.project
  account_id   = "github-actions"
  display_name = "GitHub Actions Service Account for deploy"
}

resource "google_project_iam_member" "github_actions_default" {
  project = var.project
  for_each = toset([
    "roles/logging.logWriter",
    "roles/errorreporting.writer",
    "roles/cloudprofiler.agent",
    "roles/cloudtrace.agent",
    "roles/monitoring.metricWriter",
    "roles/cloudbuild.builds.builder",
    "roles/iam.serviceAccountUser",
    "roles/run.admin",
  ])
  member = "serviceAccount:${google_service_account.github_actions.email}"
  role   = each.value
}

#　terraform plan -target={resource} terraform apply -target={resource}
