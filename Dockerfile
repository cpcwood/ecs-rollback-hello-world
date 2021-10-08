FROM golang:1-alpine as build

WORKDIR /app
COPY ./hello.go /app
RUN go build /app/hello.go

FROM alpine:latest
WORKDIR /app
COPY --from=build /app/hello /app/hello

EXPOSE 8080
ENTRYPOINT ["./hello"]
