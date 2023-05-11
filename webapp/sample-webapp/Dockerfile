# Docker image to build sample-webapp
# Please edit this file to adapt language.
FROM golang:1.20.4

WORKDIR /app

COPY go.mod ./
COPY go.sum ./

RUN go mod download