FROM --platform=${BUILDPLATFORM:-linux/amd64} golang:1.20-bullseye as builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETOS
ARG TARGETARCH

WORKDIR /app
COPY go.* .
RUN go mod download
COPY . .
ARG CGO_ENABLED=0
RUN --mount=type=cache,target=/root/.cache/go-build  GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -ldflags="-w -s" -o certsync *.go


FROM alpine:3.18 as certs

RUN apk add -U --no-cache ca-certificates

FROM scratch as app

WORKDIR /app

COPY --from=builder /app/certsync /app/certsync
COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

ENTRYPOINT [ "/app/certsync" ]
