# Bitcoin Core als lokale Kopie einrichten

> **Hinweis:**
>
> Ersetze in dieser Anleitung **`$HOME`** durch die Ausgabe von:
>
> ```bash
> cd && pwd
> ```

---

# 1. Bitcoin Core: Konsens ändern (SegWit ab Block 1) und neu kompilieren

## 1.1 Source herunterladen

```bash
cd
wget https://bitcoincore.org/bin/bitcoin-core-31.0/bitcoin-31.0.tar.gz
```

## 1.2 Entpacken

```bash
tar -xzf bitcoin-31.0.tar.gz
cd bitcoin-core-31.0
```

## 1.3 Konsens anpassen

```bash
sed -i 's/consensus\.SegwitHeight *= *.*/consensus.SegwitHeight = 1;/' src/kernel/chainparams.cpp
```

(Optional prüfen)

```bash
grep SegwitHeight src/kernel/chainparams.cpp
```

## 1.4 Notwendige Bibliotheken installieren

```bash
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
```

## 1.5 Bitcoin Core kompilieren

```bash
cmake -B build
cmake --build build -j$(nproc)
cd ..
```

## 1.6 Fertig

Die kompilierten Programme befinden sich unter:

```text
$HOME/bitcoin-core-31.0/build/bin
```

---

# 2. Blockchain bis zur gewünschten Höhe initialisieren (z. B. 10000 Blöcke)

## 2.1 Arbeitsverzeichnis erstellen

```bash
mkdir $HOME/btcnode
```

## 2.2 Konfigurationsdatei erstellen

```bash
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
```

## 2.3 Node starten und bis Block 10000 synchronisieren

```bash
$HOME/bitcoin-core-31.0/build/bin/bitcoind \
-datadir=$HOME/btcnode \
-stopatheight=10000
```

## 2.4 `bitcoin.conf` anpassen

Die `connect`-Zeile auskommentieren:

```bash
sed -i 's/^connect=127\.0\.0\.1:18444/#connect=127.0.0.1:18444/' $HOME/btcnode/bitcoin.conf
```

## 2.5 Node starten

```bash
$HOME/bitcoin-core-31.0/build/bin/bitcoind \
-datadir=$HOME/btcnode \
-daemon
```

## 2.6 Funktion testen

```bash
$HOME/bitcoin-core-31.0/build/bin/bitcoin-cli \
-datadir=$HOME/btcnode \
getblockcount
```

## 2.7 Wallet `mylocalwallet` erstellen

```bash
$HOME/bitcoin-core-31.0/build/bin/bitcoin-cli \
-datadir=$HOME/btcnode \
createwallet mylocalwallet
```

## 2.8 Node beenden

```bash
$HOME/bitcoin-core-31.0/build/bin/bitcoin-cli \
-datadir=$HOME/btcnode \
stop
```

---

# 3. Zweiten Netzwerkteilnehmer erstellen

> Ein Netzwerk besteht aus mindestens zwei Teilnehmern.

## 3.1 Node kopieren

```bash
cp -r $HOME/btcnode $HOME/btcpeer
```

## 3.2 Neue Node bereinigen

```bash
rm $HOME/btcpeer/peers.json
rm $HOME/btcpeer/anchors.dat
```

## 3.3 Konfigurationsdatei anpassen

```bash
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
```

## 3.4 Neuen Teilnehmer starten

```bash
$HOME/bitcoin-core-31.0/build/bin/bitcoind \
-datadir=$HOME/btcpeer \
-daemon
```

## 3.5 Hauptnode starten

```bash
$HOME/bitcoin-core-31.0/build/bin/bitcoind \
-datadir=$HOME/btcnode \
-daemon
```

## 3.6 Wallet laden

```bash
$HOME/bitcoin-core-31.0/build/bin/bitcoin-cli \
-datadir=$HOME/btcnode \
loadwallet mylocalwallet
```

---

# Fertig 🎉

## Blockhöhe prüfen

```bash
$HOME/bitcoin-core-31.0/build/bin/bitcoin-cli \
-datadir=$HOME/btcnode \
getblockcount
```

## Blockchain-Informationen anzeigen

```bash
$HOME/bitcoin-core-31.0/build/bin/bitcoin-cli \
-datadir=$HOME/btcnode \
getblockchaininfo
```

## Blocktemplate mit SegWit-Regeln abrufen

```bash
$HOME/bitcoin-core-31.0/build/bin/bitcoin-cli \
-datadir=$HOME/btcnode \
getblocktemplate '{"rules":["segwit"]}'
```
