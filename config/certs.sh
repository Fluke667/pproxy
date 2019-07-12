#!/bin/sh

mkdir -p /etc/certs/ssl/
SUBJ="/C=$CRT_COUNTY/ST=$CRT_STATE/L=$CRT_LOCATION/O=$CRT_ORGANISATION"

if [ ! -f "$CRT_CERT_DIR/$CRT_ROOT_NAME.crt" ]
then
  # generate root certificate
  ROOT_SUBJ="$SUBJ/CN=$CRT_ROOT_CN"

  echo " ---> Generate Root CA private key"
  openssl genrsa \
    -out "$CRT_CERT_DIR/$CRT_ROOT_NAME.key" \
    "$CRT_RSA_KEY_NUMBITS"

  echo " ---> Generate Root CA certificate request"
  openssl req \
    -new \
    -key "$CRT_CERT_DIR/$CRT_ROOT_NAME.key" \
    -out "$CRT_CERT_DIR/$CRT_ROOT_NAME.csr" \
    -subj "$ROOT_SUBJ"

  echo " ---> Generate self-signed Root CA certificate"
  openssl req \
    -x509 \
    -key "$CRT_CERT_DIR/$CRT_ROOT_NAME.key" \
    -in "$CRT_CERT_DIR/$CRT_ROOT_NAME.csr" \
    -out "$CRT_CERT_DIR/$CRT_ROOT_NAME.crt" \
    -days "$CRT_DAYS"
else
  echo "ENTRYPOINT: $CRT_ROOT_NAME.crt already exists"
fi

if [ ! -f "$CRT_CERT_DIR/$CRT_ISSUER_NAME.crt" ]
then
  # generate issuer certificate
  ISSUER_SUBJ="$SUBJ/CN=$CRT_ISSUER_CN"

  echo " ---> Generate Issuer private key"
  openssl genrsa \
    -out "$CRT_CERT_DIR/$CRT_ISSUER_NAME.key" \
    "$CRT_RSA_KEY_NUMBITS"

  echo " ---> Generate Issuer certificate request"
  openssl req \
    -new \
    -key "$CRT_CERT_DIR/$CRT_ISSUER_NAME.key" \
    -out "$CRT_CERT_DIR/$CRT_ISSUER_NAME.csr" \
    -subj "$ISSUER_SUBJ"

  echo " ---> Generate Issuer certificate"
  openssl x509 \
    -req \
    -in "$CRT_CERT_DIR/$CRT_ISSUER_NAME.csr" \
    -CA "$CRT_CERT_DIR/$CRT_ROOT_NAME.crt" \
    -CAkey "$CRT_CERT_DIR/$CRT_ROOT_NAME.key" \
    -out "$CRT_CERT_DIR/$CRT_ISSUER_NAME.crt" \
    -CAcreateserial \
    -extfile issuer.ext \
    -days "$CRT_DAYS"
else
  echo "ENTRYPOINT: $CRT_ISSUER_NAME.crt already exists"
fi

if [ ! -f "$CRT_CERT_DIR/$CRT_PUBLIC_NAME.key" ]
then
  # generate public rsa key
  echo " ---> Generate private key"
  openssl genrsa \
    -out "$CRT_CERT_DIR/$CRT_PUBLIC_NAME.key" \
    "$CRT_RSA_KEY_NUMBITS"
else
  echo "ENTRYPOINT: $CRT_PUBLIC_NAME.key already exists"
fi

if [ ! -f "$CRT_CERT_DIR/$CRT_PUBLIC_NAME.crt" ]
then
  # generate public certificate
  echo " ---> Generate public certificate request"
  PUBLIC_SUBJ="$SUBJ/CN=$CRT_PUBLIC_CN"
  openssl req \
    -new \
    -key "$CRT_CERT_DIR/$CRT_PUBLIC_NAME.key" \
    -out "$CRT_CERT_DIR/$CRT_PUBLIC_NAME.csr" \
    -subj "$PUBLIC_SUBJ"

  # append public cn to subject alt names
  echo "DNS.1 = $CRT_PUBLIC_CN" >> public.ext

  echo " ---> Generate public certificate signed by $CRT_ISSUER_CN"
  openssl x509 \
    -req \
    -in "$CRT_CERT_DIR/$CRT_PUBLIC_NAME.csr" \
    -CA "$CRT_CERT_DIR/$CRT_ISSUER_NAME.crt" \
    -CAkey "$CRT_CERT_DIR/$CRT_ISSUER_NAME.key" \
    -out "$CRT_CERT_DIR/$CRT_PUBLIC_NAME.crt" \
    -CAcreateserial \
    -extfile public.ext \
    -CRT_DAYS "$CRT_DAYS"
else
  echo "ENTRYPOINT: $CRT_PUBLIC_NAME.crt already exists"
fi

if [ ! -f "$CRT_CERT_DIR/ca.pem" ]
then
  # make combined root and issuer ca.pem
  echo " ---> Generate a combined root and issuer ca.pem"
  cat "$CRT_CERT_DIR/$CRT_ISSUER_NAME.crt" "$CRT_CERT_DIR/$CRT_ROOT_NAME.crt" > "$CRT_CERT_DIR/ca.pem"
else
  echo "ENTRYPOINT: ca.pem already exists"
fi

if [ ! -f "$CRT_CERT_DIR/$CRT_KEYSTORE_NAME.pfx" ]
then
  # make PKCS12 keystore
  echo " ---> Generate $CRT_KEYSTORE_NAME.pfx"
  openssl pkcs12 \
    -export \
    -in "$CRT_CERT_DIR/$CRT_PUBLIC_NAME.crt" \
    -inkey "$CRT_CERT_DIR/$CRT_PUBLIC_NAME.key" \
    -certfile "$CRT_CERT_DIR/ca.pem" \
    -password "pass:$CRT_KEYSTORE_PASS" \
    -out "$CRT_CERT_DIR/$CRT_KEYSTORE_NAME.pfx"
else
  echo "ENTRYPOINT: $CRT_KEYSTORE_NAME.pfx already exists"
fi

# run command passed to docker run
exec "$@"

