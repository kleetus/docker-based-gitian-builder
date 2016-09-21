#!/bin/bash

if [ -z "${GITIANSIGS_DIR}" ]; then 
  GITIANSIGS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"/gitian.sigs
fi
if [ -z "${SIGNER}" ]; then 
  SIGNER=`whoami`
fi
if [ -z "${COMMIT}" ]; then
  COMMIT=v0.12.1-bitcore-4
fi

for i in ./result/*.yml; do 
  config=
  signingdir=$GITIANSIGS_DIR/$COMMIT-$CONFIG/$SIGNER
  echo "signing $i and moving $i and $i.sig over to $signingdir..." 
  mkdir -p $signingdir 
  gpg -b $i 
  cp $i $i.sig $GITIANSIGS_DIR/$COMMIT-$CONFIG/$SIGNER/
  rm -fr $i $i.sig
done

