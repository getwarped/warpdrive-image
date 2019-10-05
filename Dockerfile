ARG PYTHON_BASE_VERSION=3.7

FROM python:$PYTHON_BASE_VERSION

COPY usr/bin/. /usr/bin/

RUN apt-get update && apt-get -yq dist-upgrade && \
    apt-get install -yq --no-install-recommends \
      locales sudo vim supervisor apache2 apache2-dev && \
    rm -rf /var/lib/apt/lists/* && \
    echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen && \
    sed -i.bak -e '1i auth requisite pam_deny.so' /etc/pam.d/su && \
    sed -i.bak -e 's/^%sudo/#%sudo/' /etc/sudoers && \
    useradd -u 1001 -N -g 0 -M -d /opt/app-root/src default && \
    mkdir -p /opt/app-root/src && \
    chown -R 1001:0 /opt/app-root && \
    fix-permissions /opt/app-root && \
    chmod g+w /etc/passwd

WORKDIR /opt/app-root/src

ENV HOME=/opt/app-root/src \
    PATH=/opt/app-root/src/bin:/opt/app-root/bin:$PATH \
    PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8

USER 1001

COPY --chown=1001:0 opt/app-root/. /opt/app-root/

RUN python3 -m venv /opt/app-root/venv && \
    . /opt/app-root/venv/bin/activate && \
    pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir mod_wsgi==4.6.7 warpdrive==0.31.0 && \
    fix-permissions /opt/app-root

ENV BASH_ENV=/opt/app-root/etc/profile \
    ENV=/opt/app-root/etc/profile \
    PROMPT_COMMAND=". /opt/app-root/etc/profile"

ENTRYPOINT [ "container-entrypoint" ]

CMD [ "container-usage" ]
