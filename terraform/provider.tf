provider "google" {
  project = var.project
  region  = "asia-northeast1"
}

#terraform {
#  cloud {
#    organization = "hayashiki"
#
#    workspaces {
#      name = "go-boiler"
#    }
#  }
#}
