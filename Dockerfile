ARG TARGETARCH
ARG OS=linux


FROM --platform=$OS/$TARGETARCH alpine:3.21.0 AS builder

ARG TARGETARCH
ARG OS

ENV TARGETARCH=$TARGETARCH
ENV OS=$OS

USER root
WORKDIR /temp

# RUN apt update && apt -y install \
#     cmake \
#     gcc \
#     g++ \
#     make \
#     pkgconf \
#     libncurses5-dev \
#     libssl-dev \
#     libsodium-dev \
#     libreadline-dev \
#     zlib1g-dev \
#     git \
#     && git clone https://github.com/SoftEtherVPN/SoftEtherVPN.git \
#     && cd /temp/SoftEtherVPN \  
#     && git submodule init && git submodule update \
#     && ./configure \
#     && make -C build \
#     && apt-get clean && rm -rf /var/lib/apt/lists/*


RUN apk update && apk add --no-cache \
    cmake \
    gcc \
    g++ \
    make \
    pkgconf \
    ncurses-dev \
    openssl-dev \
    libsodium-dev \
    readline-dev \
    zlib-dev \
    libc6-compat \
    linux-headers \
    git \
    && git clone https://github.com/SoftEtherVPN/SoftEtherVPN.git \
    && cd /temp/SoftEtherVPN \
    && git submodule init && git submodule update \
    && ./configure \
    && make -C build \
    && rm -rf /var/cache/apk/*


FROM --platform=$OS/$TARGETARCH alpine:3.21.0 AS base
WORKDIR /temp
USER root

EXPOSE 500/udp 4500/udp 1701/tcp 1194/udp 1194/tcp 443/tcp 5555/tcp 992/tcp


COPY --from=builder /temp/SoftEtherVPN/build /temp
COPY app/run.sh /temp/run.sh


RUN export PATH=$PATH:/usr/local/lib:/app \
    && chmod +x /temp/run.sh \
    && apk update \
    && apk add --no-cache \
    bash \
    nano \
    curl \
    net-tools \
    libsodium-dev \
    readline-dev \
    iputils \
    && rm -rf /var/cache/apk/*




ENTRYPOINT [ "sh", "/temp/run.sh" ]