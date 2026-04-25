# Stage 1: Build
FROM golang:1.26-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /shippingservice .

# Stage 2: Run
FROM alpine:3.21

WORKDIR /app

COPY --from=builder /shippingservice ./

ENV APP_PORT=50051
EXPOSE 50051

ENTRYPOINT ["/app/shippingservice"]
