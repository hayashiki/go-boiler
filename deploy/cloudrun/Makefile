GCP_PROJECT := $(shell gcloud config get-value project)
GCP_PROJECT_NUMBER=$(shell gcloud projects describe ${GCP_PROJECT} --format="get(projectNumber)")
SERVICE_NAME := "go-boiler-api"
CLOUDRUN_SA=${SERVICE_NAME}@${PROJECT_ID}.iam.gserviceaccount.com

create-sa:
	gcloud iam service-accounts create $(SERVICE_NAME) \
		--display-name "$(SERVICE_NAME) service account"

enable:
	gcloud services enable run.googleapis.com
	gcloud services enable iam.googleapis.com
	gcloud services enable compute.googleapis.com
	gcloud services enable cloudbuild.googleapis.com
	gcloud services enable cloudkms.googleapis.com
	gcloud services enable cloudresourcemanager.googleapis.com
	gcloud services enable secretmanager.googleapis.com

sa:
	@echo $(CLOUDRUN_SA)
