# Build Stage:
FROM golang:1.18

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential

## Add Source Code
ADD . /golisp
WORKDIR /golisp

## Build Step
RUN go mod tidy
RUN go build cmd/golisp/main.go