ARG NODE_IMAGE=registry.suse.com/bci/nodejs:20
ARG BCI_IMAGE=registry.suse.com/bci/bci-base:16.0

FROM ${NODE_IMAGE} AS builder
RUN zypper --non-interactive install -y git tar gzip
ARG PKG
ARG TAG
RUN git clone --depth=1 https://${PKG}.git /src
WORKDIR /src
RUN git fetch --all --tags --prune && git checkout tags/${TAG} -b ${TAG}
WORKDIR /src/whisker
RUN corepack enable || npm install -g yarn
RUN yarn install --frozen-lockfile || yarn install
RUN yarn build

# Static assets served by nginx from a minimal SLE BCI base image.
FROM ${BCI_IMAGE} AS hardened-calico-whisker
LABEL org.opencontainers.image.description="Calico Whisker UI"
RUN zypper --non-interactive install -y nginx && \
    zypper --non-interactive clean -a
COPY --from=builder /src/whisker/dist /usr/share/nginx/html/
COPY --from=builder /src/whisker/docker-image/nginx.conf /etc/nginx/nginx.conf
COPY --from=builder /src/whisker/docker-image/default.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /src/whisker/docker-image/nginx-start.sh /usr/bin/nginx-start.sh
RUN chmod +x /usr/bin/nginx-start.sh
EXPOSE 8081
ENTRYPOINT ["/usr/bin/nginx-start.sh"]
