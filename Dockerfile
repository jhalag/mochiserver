FROM golang:1.23-bookworm AS builder

RUN apt-get update
RUN apt-get install git

WORKDIR /app

COPY go.mod ./
COPY go.sum ./
RUN go mod download

COPY . ./

RUN CGO_ENABLED=0 go build -o /app/mochi ./cmd/docker

# FROM redhat/ubi9
FROM busybox:stable-glibc

WORKDIR /
COPY --from=builder /app/mochi .
RUN mkdir /data
HEALTHCHECK CMD /bin/wget --spider http://localhost:1880/healthcheck || exit 1


ENTRYPOINT [ "/mochi", "--config", "data/config.yaml" ]