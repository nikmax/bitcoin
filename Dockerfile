FROM debian:stable-slim

ENV BITCOIN_VERSION=31.0
ENV BITCOIN_SRC=/opt/bitcoin-core-31.0
ENV PATH="/opt/bitcoin-${BITCOIN_VERSION}/build/bin:${PATH}"

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    wget \
    ca-certificates \
    build-essential \
    cmake \
    pkg-config \
    ninja-build \
    capnproto \
    libcapnp-dev \
    libevent-dev \
    libboost-dev \
    libsqlite3-dev \
    libzmq3-dev \
    libminiupnpc-dev \
    libnatpmp-dev \
    libdb-dev \
    libdb++-dev \
    libevent-2.1-7 \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

RUN wget https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/bitcoin-${BITCOIN_VERSION}.tar.gz
RUN tar -xzf bitcoin-${BITCOIN_VERSION}.tar.gz
RUN rm bitcoin-${BITCOIN_VERSION}.tar.gz
RUN cd bitcoin-${BITCOIN_VERSION} \
 && sed -i 's/consensus\.SegwitHeight *= *.*/consensus.SegwitHeight = 1;/' src/kernel/chainparams.cpp \
 && cmake -B build . \
 && cmake --build build -j$(nproc)

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8333 8332

ENTRYPOINT ["/entrypoint.sh"]
