FROM golang:1.20-bullseye as builder

WORKDIR /app

COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -tags netgo -ldflags '-w' -o certsync *.go

FROM alpine:3.18 as certs

RUN apk add -U --no-cache ca-certificates

FROM scratch as app

WORKDIR /app

COPY --from=builder /app/certsync /app/certsync
COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

ENTRYPOINT [ "/app/certsync" ]
