FROM golang:1.17-alpine AS build-env

WORKDIR /app
COPY go.mod .
COPY go.sum .
RUN apk add --no-cache upx && \
    go version && \
    go mod download
COPY . .
RUN CGO_ENABLED=0 go build -trimpath -ldflags '-w -s' -o /go/bin/api && upx /go/bin/api

FROM scratch
COPY --from=build-env /go/bin/api /go/bin/api
ENTRYPOINT ["/go/bin/api"]
