#!/usr/bin/env bash
set -e


if [ ! -f /root/.bitcoin/bitcoin.conf ]; then

mkdir /root/btcnode

cat <<EOF > /root/btcnode/bitcoin.conf
datadir=/root/btcnode
fallbackfee=0.00001
server=1
port=8333
rpcport=8332
#connect=127.0.0.1:18444
listen=1
dnsseed=0
maxtipage=999999999
minimumchainwork=0000000000000000000000000000000000000000000000000000000000000000
discover=0
listenonion=0
EOF


bitcoind -datadir=/root/btcnode -stopatheight=100
sed -i 's/^#connect=127\.0\.0\.1:18444/connect=127.0.0.1:18444/' /root/btcnode/bitcoin.conf 

cp -r /root/btcnode /root/btcpeer

cat <<EOF > /root/btcpeer/bitcoin.conf
datadir=/root/btcpeer
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

rm -f /root/btcpeer/peers.json /root/btcpeer/anchors.dat

mkdir /root/.bitcoin && cp /root/btcnode/bitcoin.conf /root/.bitcoin/
fi
bitcoind -datadir=/root/btcpeer -daemon
bitcoind -datadir=/root/btcnode -printtoconsole
