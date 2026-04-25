# Stage 1: Build
FROM golang:1.26-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /server .

# Stage 2: Run
FROM alpine:3.21

WORKDIR /app

COPY --from=builder /server ./
COPY products.json ./

EXPOSE 3550

ENTRYPOINT ["/app/server"]
