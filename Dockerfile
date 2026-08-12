FROM node:20-alpine3.19 AS example
LABEL maintainer Ascensio System SIA <support@onlyoffice.com>

ARG EXAMPLE_BRANCH=master
ARG EXAMPLE_REPO=https://github.com/ONLYOFFICE/document-server-integration.git

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    NODE_ENV=production-linux \
    NODE_CONFIG_DIR=/etc/onlyoffice/documentserver-example/

WORKDIR /var/www/onlyoffice/documentserver-example/

RUN --mount=type=secret,id=example_token,required=false \
    apk update && \
    apk add git && \
    if [ -s /run/secrets/example_token ]; then \
      EXAMPLE_TOKEN="$(tr -d '\r\n' < /run/secrets/example_token)"; \
      EXAMPLE_HOST="$(printf '%s' "${EXAMPLE_REPO}" | sed -E 's#^(https?://[^/]+)/.*#\1/#')"; \
      export GIT_CONFIG_COUNT=1; \
      export GIT_CONFIG_KEY_0="http.${EXAMPLE_HOST}.extraheader"; \
      export GIT_CONFIG_VALUE_0="Authorization: Basic $(printf '%s:' "${EXAMPLE_TOKEN}" | base64 | tr -d '\r\n')"; \
    fi && \
    git clone \
      --depth 1 \
      --recurse-submodules \
      --branch "${EXAMPLE_BRANCH}" \
      "${EXAMPLE_REPO}" document-server-integration && \
    mkdir -p /var/www/onlyoffice/documentserver-example && \
    cp -r ./document-server-integration/web/documentserver-example/nodejs/. \
      /var/www/onlyoffice/documentserver-example/ && \
    rm -rf ./document-server-integration && \
    addgroup -S -g 1001 ds && \
    adduser \
      -S \
      -G ds \
      -D \
      -h /var/www/onlyoffice/documentserver-example \
      -s /sbin/nologin \
      -u 1001 ds && \
    chown -R ds:ds /var/www/onlyoffice/documentserver-example/ && \
    mkdir -p /var/lib/onlyoffice/documentserver-example/ && \
    chown -R ds:ds /var/lib/onlyoffice/ && \
    mv files /var/lib/onlyoffice/documentserver-example/ && \
    mkdir -p /etc/onlyoffice/documentserver-example/ && \
    chown -R ds:ds /etc/onlyoffice/ && \
    mv config/* /etc/onlyoffice/documentserver-example/ && \
    ln -s /etc/onlyoffice/documentserver-example/data.json \
    /var/www/onlyoffice/documentserver-example/config/data.json && \
    npm install

EXPOSE 3000

USER ds

ENTRYPOINT ["/var/www/onlyoffice/documentserver-example/docker-entrypoint.sh", "npm", "start"]
