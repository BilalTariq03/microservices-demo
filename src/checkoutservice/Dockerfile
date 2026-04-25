# Stage 1: Build
FROM golang:1.26-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /checkoutservice .

# Stage 2: Run
FROM alpine:3.21

WORKDIR /app

COPY --from=builder /checkoutservice ./

EXPOSE 5050

ENTRYPOINT ["/app/checkoutservice"]
