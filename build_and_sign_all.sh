#!/bin/bash
set -e

#pushd ./bitcoin
export SIGNER=kleetus
export VERSION=v0.12.1-bitcore-2
#git fetch
#git checkout ${VERSION}
#popd

#pushd gitian-builder
#this repo may be out of date, leading to differences in digests of output artifacts
#git pull origin master
export URL=https://github.com/bitpay/bitcoin.git
export COMMIT=v0.12.1-bitcore-2

#linux 32/64
cmd="./bin/gbuild --allow-sudo --commit bitcoin=${COMMIT} --url bitcoin=${URL} ../bitcoin/contrib/gitian-descriptors/gitian-linux.yml"
echo $cmd
exit 0
./bin/gsign --signer $SIGNER --release ${VERSION}-linux --destination ../gitian.sigs/ ../bitcoin/contrib/gitian-descriptors/gitian-linux.yml
mv build/out/bitcoin-*.tar.gz build/out/src/bitcoin-*.tar.gz ../


#os x 64
./bin/gbuild --commit bitcoin=${COMMIT} --url bitcoin=${URL} ../bitcoin/contrib/gitian-descriptors/gitian-osx.yml
./bin/gsign --signer $SIGNER --release ${VERSION}-osx-unsigned --destination ../gitian.sigs/ ../bitcoin/contrib/gitian-descriptors/gitian-osx.yml
mv build/out/bitcoin-*-osx-unsigned.tar.gz inputs/bitcoin-osx-unsigned.tar.gz
mv build/out/bitcoin-*.tar.gz build/out/bitcoin-*.dmg ../


popd
