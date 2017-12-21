FROM nginx
MAINTAINER Anthony Bretaudeau <anthony.bretaudeau@inra.fr>
ENV DEBIAN_FRONTEND noninteractive

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

RUN mkdir /opt/gcv && \
    cd /opt/gcv && \
    git clone https://github.com/legumeinfo/lis_context_viewer.git . && \
    cd server && \
    pip install -r requirements.txt

RUN cd /opt/gcv/client && \
    npm install && \
    npm run build && \
    rm -rf /usr/share/nginx/html && \
    cp config.json dist/ && \
    ln -s /opt/gcv/client/dist/ /usr/share/nginx/html

WORKDIR /opt/gcv

ADD entrypoint.sh /

CMD ["/entrypoint.sh"]
