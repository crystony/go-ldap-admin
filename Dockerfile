FROM node:14 AS ui

WORKDIR /app
COPY . .
WORKDIR /app/ui

RUN sed -i 's@http://localhost:8888/@/@g' .env.production \
    && git config --global url."https://".insteadOf git:// \
    && npm install \
    && yarn build:prod \
    && ls -alh dist


FROM golang:1.24.2-alpine AS builder

WORKDIR /app

ENV GOPROXY=https://goproxy.io

COPY . .
COPY --from=ui /app/ui/dist /tmp/dist

RUN ls -ahlt /tmp/dist

RUN sed -i "s/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g" /etc/apk/repositories \
    && apk upgrade && apk add --no-cache --virtual .build-deps ca-certificates gcc g++ curl \
    \
#    && release_url=$(curl -s https://api.github.com/repos/eryajf/go-ldap-admin-ui/releases/latest | grep "browser_download_url" | grep -v 'dist.zip.md5' | cut -d '"' -f 4) \
#    && release_url=$(curl -s https://api.github.com/repositories/493604204/releases/latest | grep "browser_download_url" | grep -v 'dist.zip.md5' | cut -d '"' -f 4) \
#    && wget $release_url  \
#    && unzip dist.zip  \
#    && rm dist.zip  \
#    && rm -rf public/static/dist \
#    && mv dist public/static/ \
    && mv /tmp/dist public/static/ \
    \
    && sed -i 's@localhost:389@openldap:389@g' /app/config.yml \
    && sed -i 's@host: localhost@host: mysql@g'  /app/config.yml  \
    && go build -o go-ldap-admin .

### build final image
FROM alpine:3.21

WORKDIR /app

COPY --from=builder /app/LICENSE .
COPY --from=builder /app/config.yml .
COPY --from=builder /app/go-ldap-admin .

RUN chmod +x go-ldap-admin

CMD ./go-ldap-admin
