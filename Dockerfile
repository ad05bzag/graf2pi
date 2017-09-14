#Cross build Grafana master for armv6-v7 wheezy/jessie
FROM debian:jessie

ARG LABEL=master
ARG DEPTH=1
ARG COMMIT

ENV LABEL=${LABEL} \
    DEPTH=${DEPTH} \
    PATH=/usr/local/go/bin:$PATH \
    GOPATH=/tmp/graf-build \
    NODEVERSION=6.11.3 \
    GOVERSION=1.9

RUN apt-get update       && \
    apt-get install -y      \
        apt-transport-https \
        binutils            \
        bzip2               \
        ca-certificates     \
        curl                \
        g++                 \
        gcc                 \
        git                 \
        libc-dev            \
        libfontconfig1      \
        make                \
        python              \
        ruby                \
        ruby-dev            \
        xz-utils        &&  \
    gem install --no-ri --no-rdoc fpm      && \
    curl -sSL https://storage.googleapis.com/golang/go${GOVERSION}.linux-amd64.tar.gz \
      | tar -xz -C /usr/local && \
    curl -sSL https://nodejs.org/dist/v${NODEVERSION}/node-v${NODEVERSION}-linux-x64.tar.xz    \
      | tar -xJ --strip-components=1 -C /usr/local && \
    mkdir -p $GOPATH/src/github.com/grafana    && \
    mkdir -p $GOPATH/src/github.com/ad05bzag    && \
    cd $GOPATH/src/github.com/ad05bzag          && \
    git clone -b ${LABEL} --depth ${DEPTH} --single-branch https://github.com/ad05bzag/grafana.git && \
    ln -s  $GOPATH/src/github.com/ad05bzag/grafana $GOPATH/src/github.com/grafana/grafana && \
    cd $GOPATH/src/github.com/grafana/grafana  && \
    git checkout ${COMMIT}                     && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb [arch=amd64] https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install yarn     && \
    yarn install --ignore-engines --pure-lockfile               && \
    go run build.go setup

COPY ./build.sh /

RUN chmod 700 /build.sh

CMD ["/bin/bash"]
