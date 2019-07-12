FROM alpine:3.10
MAINTAINER Fluke667 <Fluke667@gmail.com>  
ARG TZ='Europe/Berlin'
ENV TZ ${TZ}
#ENV LANG=C.UTF-8



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

EXPOSE 8060/tcp
EXPOSE 8070/tcp
EXPOSE 8080/tcp
EXPOSE 8090/tcp

VOLUME ["/etc/ssl/certs"]

#COPY pproxy.sh /
#RUN chmod +x /pproxy.sh
#ENTRYPOINT ["/pproxy.sh"]

ADD ./config /config
RUN chmod 0700 /config/*.sh
RUN /config/cert.sh \
    /config/pproxy.sh
