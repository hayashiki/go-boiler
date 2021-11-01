resource "google_storage_bucket" "tf_example" {
  project  = var.project
  name     = "go-boiler-${var.env}-tf-state"
  location = "asia"

  versioning {
    enabled = true
  }
}
