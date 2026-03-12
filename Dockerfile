FROM postgres:18-alpine

RUN set -eu -o pipefail \
    && apk add --no-cache --virtual .plpython3-deps --repository http://nl.alpinelinux.org/alpine/edge/testing postgresql-plpython3 py3-pip \
    && python3 -m pip install --break-system-packages cryptography textblob tabulate \
    && python3 -c 'from cryptography.fernet import Fernet; open("/var/tmp/secret.key", "wb").write(Fernet.generate_key())' \
    && rm -rf ~/.cache/pip/* \
    && rm -rf /var/cache/apk/*
