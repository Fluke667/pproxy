FROM alpine:3.9
MAINTAINER Fluke667 <Fluke667@gmail.com>  
ARG TZ='Europe/Berlin'
ENV TZ ${TZ}

RUN apk --no-cache add \
    build-base \
    git \
    linux-headers \
    openssh \
    openssl \
    openssl-dev \
    python3 \
    python3-dev \
    gnupg \
    sqlite \
    sqlite-libs \
    sqlite-dev \
    readline \
    bzip2 \
    libbz2 \
    expat \
    gdbm \      
    xz-dev \
    libffi \
    libffi-dev \
    nano \
    && pip3 install --upgrade pip
    
# Install Requirements
RUN pip3 install asn1crypto asyncssh cffi cryptography pproxy pycparser pycryptodome setuptools six

EXPOSE 8010/tcp
EXPOSE 8020/tcp
EXPOSE 8030/tcp
EXPOSE 8040/tcp
EXPOSE 8050/tcp
EXPOSE 8080/tcp

VOLUME ["/data/pproxy"]

ENTRYPOINT [ "pproxy" ]
