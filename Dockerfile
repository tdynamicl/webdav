FROM golang:1.26-alpine3.22 AS build

ARG VERSION="untracked"

# Use a reachable Go module proxy. proxy.golang.org is not reachable in some
# networks; goproxy.cn (and goproxy.io as a fallback) mirrors the public index.
ENV GOPROXY=https://goproxy.cn,https://goproxy.io,direct \
    GOSUMDB=sum.golang.google.cn

WORKDIR /webdav/

COPY ./go.mod ./
COPY ./go.sum ./
RUN go mod download

COPY . /webdav/
RUN go build -o main -trimpath -ldflags="-s -w -X 'github.com/hacdias/webdav/v5/cmd.version=$VERSION'" .

FROM scratch

COPY --from=build /webdav/main /bin/webdav

EXPOSE 6065

ENTRYPOINT [ "webdav" ]
