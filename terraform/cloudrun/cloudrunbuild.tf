resource "google_project_service" "cloudbuild" {
  service = "cloudbuild.googleapis.com"
}

resource "google_cloudbuild_trigger" "github_torii" {
  name = "build-trigger"

  trigger_template {
    repo_name = "github_hayashiki_oimo-classification"
    branch_name = "master"
  }

  build {
    dynamic "step" {
      for_each = local.steps
      content {
        name = step.value.name
        args = step.value.args
        env  = lookup(step.value, "env", null)
      }
    }
  }
//  filename = "cloudbuild.yaml"

}

locals {
  cloudbuild_roles = [
    "roles/run.admin",
    "roles/firebase.admin",
  ]
}

// cloudbuildサービスアカウントにroleを付与する
resource "google_project_iam_binding" "cloudbuild" {
  for_each = toset(local.cloudbuild_roles)
  role = each.value

  members = ["serviceAccount:${local.project_number}@cloudbuild.gserviceaccount.com"]
}
