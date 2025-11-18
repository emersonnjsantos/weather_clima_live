# Build Stage
FROM golang:1.25-alpine AS builder

WORKDIR /app

# Install migrate
RUN go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o /weatherpro-backend ./cmd/server

# Final Stage
FROM alpine:latest

RUN apk --no-cache add ca-certificates

COPY --from=builder /go/bin/migrate /usr/local/bin/
COPY --from=builder /weatherpro-backend /weatherpro-backend
COPY migrations /migrations
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
