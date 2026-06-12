FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY go.* ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o service-b ./cmd/main.go

FROM gcr.io/distroless/static-debian12
COPY --from=builder /app/service-b /service-b
EXPOSE 8080
ENTRYPOINT ["/service-b"]
