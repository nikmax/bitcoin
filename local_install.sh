#!/usr/bin/env bash
set -e

cd
wget https://bitcoincore.org/bin/bitcoin-core-31.0/bitcoin-31.0.tar.gz

tar -xzf bitcoin-31.0.tar.gz
cd bitcoin-core-31.0

sed -i 's/consensus\.SegwitHeight *= *.*/consensus.SegwitHeight = 1;/' src/kernel/chainparams.cpp

grep SegwitHeight src/kernel/chainparams.cpp

sudo apt update && sudo apt install -y \
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
libevent-2.1-7

cmake -B build
cmake --build build -j$(nproc)
cd ..

mkdir -p $HOME/btcnode

cat << EOF > $HOME/btcnode/bitcoin.conf
# bitcoin.conf
datadir=$HOME/btcnode
fallbackfee=0.00001
server=1

#connect=127.0.0.1:18444

port=8333
rpcport=8332
#rpcuser=user
#rpcpassword=pass
#rpcbind=0.0.0.0
#rpcallowip=127.0.0.1
listen=1
dnsseed=0
maxtipage=999999999
minimumchainwork=0000000000000000000000000000000000000000000000000000000000000000
discover=0
listenonion=0
EOF

$HOME/bitcoin-core-31.0/build/bin/bitcoind \
-datadir=$HOME/btcnode \
-stopatheight=10000

sed -i 's/^connect=127\.0\.0\.1:18444/#connect=127.0.0.1:18444/' $HOME/btcnode/bitcoin.conf

$HOME/bitcoin-core-31.0/build/bin/bitcoind \
-datadir=$HOME/btcnode \
-daemon

$HOME/bitcoin-core-31.0/build/bin/bitcoin-cli \
-datadir=$HOME/btcnode \
getblockcount

$HOME/bitcoin-core-31.0/build/bin/bitcoin-cli \
-datadir=$HOME/btcnode \
createwallet mylocalwallet

$HOME/bitcoin-core-31.0/build/bin/bitcoin-cli \
-datadir=$HOME/btcnode \
stop

cp -r $HOME/btcnode $HOME/btcpeer

rm -f $HOME/btcpeer/peers.json
rm -f $HOME/btcpeer/anchors.dat

cat << EOF > $HOME/btcpeer/bitcoin.conf
# bitcoin.conf
datadir=$HOME/btcpeer
server=1
connect=127.0.0.1:8333
port=18444
rpcport=18443
listen=1
dnsseed=0
maxtipage=999999999
minimumchainwork=0000000000000000000000000000000000000000000000000000000000000000
discover=0
listenonion=0
EOF

$HOME/bitcoin-core-31.0/build/bin/bitcoind \
-datadir=$HOME/btcpeer \
-daemon

$HOME/bitcoin-core-31.0/build/bin/bitcoind \
-datadir=$HOME/btcnode \
-daemon

$HOME/bitcoin-core-31.0/build/bin/bitcoin-cli \
-datadir=$HOME/btcnode \
loadwallet mylocalwallet

$HOME/bitcoin-core-31.0/build/bin/bitcoin-cli \
-datadir=$HOME/btcnode \
getblockcount

$HOME/bitcoin-core-31.0/build/bin/bitcoin-cli \
-datadir=$HOME/btcnode \
getblockchaininfo

$HOME/bitcoin-core-31.0/build/bin/bitcoin-cli \
-datadir=$HOME/btcnode \
getblocktemplate '{"rules":["segwit"]}'
