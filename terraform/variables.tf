variable "env" {
  type = string
}
variable "project" {
  type = string
}

variable "location" {
  type    = string
  default = "asia-northeast1"
}

variable "name" {
  type    = string
  default = "go-boiler-api"
}

variable "gar_repository" {
  type    = string
  default = "hayashiki"
}

variable "image_name" {
  type    = string
  default = "go-boiler-api"
}

variable "image_tag" {
  type    = string
  default = "latest"
}

#// cloud run service account
#variable "service_account" {
#  type = string
#}
