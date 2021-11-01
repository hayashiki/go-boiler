FROM golang:1.17-alpine AS go-builder

WORKDIR /app
COPY go.mod .
COPY go.sum .
RUN apk add --no-cache upx && \
    go version && \
    go mod download
COPY . .
RUN CGO_ENABLED=0 go build -trimpath -ldflags '-w -s' -o /go/bin/api cmd/api/main.go && \
    upx /go/bin/api

FROM gcr.io/distroless/base:latest

COPY --from=go-builder /go/bin/api /go/bin/api

ENTRYPOINT ["/go/bin/api"]
