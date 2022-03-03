BIN := longcat
VERSION := $$(make -s show-version)
CURRENT_REVISION := $(shell git rev-parse --short HEAD)
BUILD_LDFLAGS := "-s -w -X main.revision=$(CURRENT_REVISION)"
GOBIN ?= $(shell go env GOPATH)/bin
export GO111MODULE=on

### GCP
GCP_PROJECT := $(shell gcloud config get-value project)
GCP_PROJECT_NUMBER=$(shell gcloud projects describe ${GCP_PROJECT} --format="get(projectNumber)")
POOL_NAME := "github-actions"
WORKLOAD_IDENTITY_POOL_ID=$(shell gcloud iam workload-identity-pools describe "${POOL_NAME}" --project="${GCP_PROJECT}" --location="global" --format="value(name)")
GITHUB_REPO:=hayashiki/go-boiler
PROVIDER_NAME=gha-provider
CI_SA_EMAIL := "ci-user@${GCP_PROJECT}.iam.gserviceaccount.com"
CLOUDBUILD_SA=${GCP_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com

### deploy / build ###

.PHONY: all
all: clean build

.PHONY: build
build:
	go build -ldflags=$(BUILD_LDFLAGS) -o $(BIN) .

.PHONY: install
install:
	go install -ldflags=$(BUILD_LDFLAGS) .

.PHONY: show-version
show-version: $(GOBIN)/gobump
	@gobump show -r .

$(GOBIN)/gobump:
	@cd && go get github.com/x-motemen/gobump/cmd/gobump

.PHONY: cross
cross: $(GOBIN)/goxz
	goxz -n $(BIN) -pv=v$(VERSION) -build-ldflags=$(BUILD_LDFLAGS) .

$(GOBIN)/goxz:
	cd && go get github.com/Songmu/goxz/cmd/goxz

.PHONY: test
test: build
	go test -v ./...

.PHONY: clean
clean:
	rm -rf $(BIN) goxz
	go clean

.PHONY: bump
bump: $(GOBIN)/gobump
ifneq ($(shell git status --porcelain),)
	$(error git workspace is dirty)
endif
ifneq ($(shell git rev-parse --abbrev-ref HEAD),master)
	$(error current branch is not master)
endif
	@gobump up -w .
	git commit -am "bump up version to $(VERSION)"
	git tag "v$(VERSION)"
	git push origin main
	git push origin "refs/tags/v$(VERSION)"

.PHONY: upload
upload: $(GOBIN)/ghr
	ghr "v$(VERSION)" goxz

$(GOBIN)/ghr:
	cd && go get github.com/tcnksm/ghr


# deploy for local
deploy:
	docker build -t $SERVICE_NAME .
	docker tag SERVICE_NAME gcr.io/$GCP_PROJECT/SERVICE_NAME:latest # github.shaとかコミットハッシュつけたほうがよい
	docker push gcr.io/$GCP_PROJECT/$SERVICE_NAME:latest # github.shaとかコミットハッシュつけたほうがよい


########################
### Terraform GCS    ###
########################
create-tf-state:
	gsutil mb -p go-boiler -l asia-northeast1 -b on gs://go-boiler-tf-state

########################
### CI Service SA    ###
########################

create-ci-sa:
	gcloud iam service-accounts create "ci-user" \
		--project=${GCP_PROJECT} \
		--display-name "CI User Service Account"

grant-role-ci:
	gcloud projects add-iam-policy-binding ${GCP_PROJECT} \
		--member serviceAccount:ci-user@${GCP_PROJECT}.iam.gserviceaccount.com \
		--role roles/owner

grant-role-sa:
	gcloud iam service-accounts add-iam-policy-binding ${CI_SA_EMAIL} \
	  --member "serviceAccount:${CLOUDBUILD_SA}" \
	  --role "roles/iam.serviceAccountUser"

#	gcloud iam service-accounts add-iam-policy-binding ${CI_SA_EMAIL} \
#		--member "serviceAccount:${CI_SA_EMAIL}" \
#		--role "roles/iam.serviceAccountUser"
#

#   個別に与える方法もあるので確認を
#   https://www.devsamurai.com/ja/gcp-terraform-service-account-permission/
#		--role roles/iam.serviceAccountUser

########################
### WorkloadIdentify ###
########################

enable:
	gcloud services enable iamcredentials.googleapis.com --project ${GCP_PROJECT}

create_pool:
	gcloud iam workload-identity-pools create ${POOL_NAME} \
		--project=${GCP_PROJECT} --location="global" \
		--display-name="use from GitHub Actions"

show_pool_id:
	$(WORKLOAD_IDENTITY_POOL_ID)
	# gcloud iam workload-identity-pools describe "github-actions" --project ${GCP_PROJECT} --location="global" --format="value(name)"

create-policy:
	gcloud iam service-accounts add-iam-policy-binding ${CI_SA_EMAIL} \
	--project=${GCP_PROJECT} \
	--role="roles/iam.workloadIdentityUser" \
	--member="principalSet://iam.googleapis.com/${WORKLOAD_IDENTITY_POOL_ID}/attribute.repository/${GITHUB_REPO}"

# # PoolにProviderを作成する
create-provider:
	gcloud iam workload-identity-pools providers create-oidc ${PROVIDER_NAME} \
	--project=${GCP_PROJECT} --location="global" \
	--workload-identity-pool=${POOL_NAME} \
	--display-name="use from GitHub Actions provider" \
	--attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository,attribute.actor=assertion.actor,attribute.aud=assertion.aud" \
	--issuer-uri="https://token.actions.githubusercontent.com"

lint: $(GOBIN)/golangci-lint
	golangci-lint run -c .golangci.yml --tests=0
	#golangci-lint run --tests=0 --disable-all -E goimports -E gofmt

$(GOBIN)/golangci-lint:
	go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.43.0

fmt:
	@find . -name '*.go' | xargs gofmt -s -w
	@find . -name '*.go' | xargs goimports -w
