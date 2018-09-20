FROM ubuntu:bionic AS builder
ENV LD_LIBRARY_PATH=/usr/local/lib:/lib
ARG PY_VER="3.7.0"

RUN mkdir -p /src && \
    mkdir -p /build

RUN apt-get -yqq update && \
    apt-get -yqq upgrade && \
    apt-get -yqq install \
        apt-utils \
        wget && \
        wget -q \
            https://www.python.org/ftp/python/${PY_VER}/Python-${PY_VER}.tar.xz \
            -P /src

RUN apt-get -yqq install \
        dpkg-dev \
        build-essential \
        zlibc \
        zlib1g \
        zlib1g-dev \
        libc6-dev \
        libffi6 \
        libffi-dev \
        libssl1.1 \
        libssl-dev \
        wget \
        binutils \
        xz-utils

RUN tar xJvf /src/Python-${PY_VER}.tar.xz -C /src

RUN cd /src/Python-${PY_VER} && \
    ./configure --enable-optimizations --enable-shared && \
    make -j install

WORKDIR /tmp
RUN mkdir -p /build_root/etc && \
    mkdir -p /build_root/usr/sbin && \
    cp -v /usr/sbin/nologin /build_root/usr/sbin/nologin

RUN apt-get download \
        libc6 \
        libffi6 \
        libssl1.1 \
        zlib1g

RUN ar xf $(ls -t libc6*.deb | head -1) data.tar.xz && \
    tar xJvf data.tar.xz -C /build_root

RUN ar xf $(ls -t libffi6*.deb | head -1) data.tar.xz && \
    tar xJvf data.tar.xz -C /build_root

RUN ar xf $(ls -t zlib1g*.deb | head -1) data.tar.xz && \
    tar xJvf data.tar.xz -C /build_root

RUN ar xf $(ls -t libssl1.1*.deb | head -1) data.tar.xz && \
    tar xJvf data.tar.xz -C /build_root

ARG APP_USER=python
RUN useradd -M -r -s /usr/sbin/nologin ${APP_USER} && \
    grep ${APP_USER} /etc/shadow > /build_root/etc/shadow && \
    grep ${APP_USER} /etc/passwd > /build_root/etc/passwd && \
    grep ${APP_USER} /etc/group  > /build_root/etc/group

FROM scratch

COPY --from=builder /build_root/ /
COPY --from=builder /usr/local/bin/ /usr/local/bin/
COPY --from=builder /usr/local/lib/ /usr/local/lib/

ENV LD_LIBRARY_PATH=/usr/local/lib:/lib
RUN ["/usr/local/bin/pip3", "install", "-U", "pip", "setuptools"]
USER python
