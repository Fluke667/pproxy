FROM alpine:3.10
MAINTAINER Fluke667 <Fluke667@gmail.com>  
ARG TZ='Europe/Berlin'

RUN apk --no-cache add \
    build-base \
    git \
    linux-headers \
    openssh \
    openssl \
    openssl-dev \
    libsodium \
    libsodium -dev \
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
    dcron \
    bash \
    && pip3 install --upgrade pip
RUN mkdir -p /var/log/cron && mkdir -m 0644 -p /var/spool/cron/crontabs && touch /var/log/cron/cron.log && mkdir -m 0644 -p /etc/cron.d
# Install Requirements
RUN pip3 install asn1crypto asyncssh cffi cryptography pproxy pycparser pycryptodome setuptools six

EXPOSE 8060
EXPOSE 8070
EXPOSE 8080
EXPOSE 8090

VOLUME ["/etc/certs/ssl"]

#COPY pproxy.sh /
#RUN chmod +x /pproxy.sh
#ENTRYPOINT ["/pproxy.sh"]

ADD ./config /config
RUN chmod 0700 /config/*.sh
RUN /config/certs.sh \
    /config/pproxy.sh
