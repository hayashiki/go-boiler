# For GitHub Actions
resource "google_service_account" "github_actions" {
  project      = var.project
  account_id   = "github-actions"
  display_name = "GitHub Actions Service Account for deploy"
}

resource "google_project_iam_member" "github_actions_default" {
  project = var.project
  for_each = toset([
    "roles/cloudbuild.builds.builder",
    "roles/iam.serviceAccountUser",
    "roles/run.admin",
    "roles/serviceusage.serviceUsageAdmin", // Enable APIs using serviceusage
    "roles/storage.admin",
#    "roles/iam.serviceAccountAdmin",
#    "roles/resourcemanager.projectIamAdmin",
  ])
  member = "serviceAccount:${google_service_account.github_actions.email}"
  role   = each.value
}

# For CloudRun Service Account
resource "google_service_account" "run_sa" {
  account_id   = "run-invoker"
  display_name = "api server identity"
}

resource "google_project_iam_member" "run_sa_default" {
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
    "roles/serviceusage.serviceUsageAdmin", // Enable APIs using serviceusage
    "roles/storage.admin",
  ])
  member = "serviceAccount:${google_service_account.github_actions.email}"
  role   = each.value
}
