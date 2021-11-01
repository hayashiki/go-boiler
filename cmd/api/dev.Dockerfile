FROM golang:1.17-alpine AS go-builder

WORKDIR /app
COPY go.mod .
COPY go.sum .
RUN apk add --no-cache upx && \
    go version && \
    go mod download
COPY . .

CMD cd cmd/api && air -c .air.toml
