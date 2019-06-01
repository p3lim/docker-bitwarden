FROM clux/muslrust:stable AS build

ENV VERSION 1.9.1

# clone source and checkout version
RUN git clone https://github.com/dani-garcia/bitwarden_rs /app --branch=$VERSION
WORKDIR /app

# compile with musl as target
RUN rustup target add x86_64-unknown-linux-musl
RUN cargo build --release --target x86_64-unknown-linux-musl

# runtime stage
FROM p3lim/alpine:3.8

# set environment variables
ENV ROCKET_ENV staging
ENV ROCKET_PORT 8080
ENV ROCKET_WORKERS 10
ENV SSL_CERT_DIR /etc/ssl/certs
ENV DATA_FOLDER /data

# install runtime dependencies
RUN apk add --no-cache openssl ca-certificates

# copy components from the build stage
RUN mkdir -p /app/migrations
WORKDIR /app
COPY --from=build /app/migrations /app/migrations/
COPY --from=build /app/Rocket.toml .
COPY --from=build /app/target/x86_64-unknown-linux-musl/release/bitwarden_rs .

# copy vault from pre-built archive
# TODO: build ourselves
ENV VERSION_VAULT v2.10.1
ENV WEB_VAULT_FOLDER /web-vault
RUN mkdir /web-vault
RUN curl -L "https://github.com/dani-garcia/bw_web_builds/releases/download/${VERSION_VAULT}/bw_web_${VERSION_VAULT}.tar.gz" | tar xz -C /web-vault
RUN chown -R abc /web-vault

# copy local files
COPY root/ /

# expose ourselves
VOLUME /data
EXPOSE 3012 8080
