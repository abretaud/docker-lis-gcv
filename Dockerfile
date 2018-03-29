FROM nginx
MAINTAINER Anthony Bretaudeau <anthony.bretaudeau@inra.fr>
ENV DEBIAN_FRONTEND noninteractive

EXPOSE 8000

RUN mkdir -p /usr/share/man/man1 /usr/share/man/man7

RUN apt-get -qq update --fix-missing && \
    apt-get --no-install-recommends -y install \
    python curl wget patch git nano postgresql-client ca-certificates gpg dirmngr \
    python-pip python-setuptools python-dev libpq-dev

ENV TINI_VERSION v0.16.1
RUN set -x \
    && curl -fSL "https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini" -o /usr/local/bin/tini \
    && curl -fSL "https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini.asc" -o /usr/local/bin/tini.asc \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver pgp.mit.edu --recv-keys 6380DC428747F6C393FEACA59A84159D7001A4E5 \
    && gpg --batch --verify /usr/local/bin/tini.asc /usr/local/bin/tini \
    && rm -r "$GNUPGHOME" /usr/local/bin/tini.asc \
    && chmod +x /usr/local/bin/tini

RUN curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
    apt-get -qq update --fix-missing && \
    apt-get --no-install-recommends -y install \
    nodejs build-essential libssl-dev

ENTRYPOINT ["/usr/local/bin/tini", "--"]

ENV SITE_NAME="lis" \
    SITE_FULL_NAME="Legume Information System" \
    SERVICES_URL="http://localhost:8000/services" \
    GCV_URL="http://localhost:8000" \
    TRIPAL_URL="https://legumeinfo.org" \
    DEBUG="false" \
    HOST="gcv"

# Patch needed for external links to tripal_phylotree
ADD PR131.diff /opt/

RUN mkdir -p /opt/gcv && \
    mkdir -p /etc/gcv && \
    cd /opt/gcv && \
    git clone https://github.com/legumeinfo/lis_context_viewer.git . && \
    git checkout b195bf434fb9bc7f280c62c1dbd82642eca63448 && \
    patch -p1 < /opt/PR131.diff && \
    cd server && \
    pip install -r requirements.txt

ADD config.json.template /etc/gcv/config.json.template
ADD settings.py /opt/gcv/server/server/settings.py
ADD header.component.html /opt/gcv/client/src/app/components/shared/header.component.html
ADD default-parameters.ts.template /etc/gcv/default-parameters.ts.template
ADD instructions/instructions.component.html /etc/gcv/instructions/instructions.component.html
ADD instructions/instructions.component.ts /opt/gcv/client/src/app/components/instructions/instructions.component.ts

RUN cd /opt/gcv/client && \
    npm install && \
    envsubst < /etc/gcv/config.json.template > src/config.json && \
    envsubst < /etc/gcv/default-parameters.ts.template > /opt/gcv/client/src/app/constants/default-parameters.ts && \
    envsubst < /etc/gcv/instructions/instructions.component.html > /opt/gcv/client/src/app/components/instructions/instructions.component.html && \
    npm run build && \
    rm -rf /usr/share/nginx/html && \
    ln -s /opt/gcv/client/dist/ /usr/share/nginx/html

WORKDIR /opt/gcv

ADD entrypoint.sh /

CMD ["/entrypoint.sh"]
