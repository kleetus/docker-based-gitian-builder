#!/bin/bash

# needs a GitHub branch or tag name -and- a org/project

# exmaple:   bash build_all_the_things.sh v0.14.1 bitcoin/bitcoin
# this will build:

#     - Mac, Linux, Windows binaries, 32 and 64 bit as well as ARM
green="\033[38;5;40m"
magenta="\033[38;5;200m"
cyan="\033[38;5;87m"
reset="\033[0m"
THISDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

check_mac () {
  if [[ "${1}" == "osx" ]] && [[ ! -f "$THISDIR/cache/MacOSX10.11.sdk.tar.gz" ]]; then
    echo -e "${magenta}MacOSX10.11.sdk.tar.gz does not exist in cache therefore OSX build not available.${reset}"
    exit -1
  fi
}

branch_or_tag="segwit2x"
if [ -n "${1}" ]; then
  branch_or_tag="${1}"
fi
repo="https://github.com/btc1/bitcoin"
if [ -n "${2}" ]; then
  repo="${2}"
fi

platforms=('linux' 'win' 'osx')

for platform in "${platforms[@]}"; do
  check_mac "${platform}"
  sdate=`date +%s`
  echo -e "${cyan}starting $platform build at: `date`${reset}"
  docker run -h builder --name builder-$sdate \
  -v $THISDIR/cache:/shared/cache:Z \
  -v $THISDIR/result:/shared/result:Z \
  builder \
  "${branch_or_tag}" \
  "${repo}" \
  "../bitcoin/contrib/gitian-descriptors/gitian-${platform}.yml" \
  edate=`date +%s`
  secs=`expr $edate - $sdate`
  hours=`expr $secs / 3600`
  secs=`expr $secs % 3600`
  mins=`expr $secs / 60`
  secs=`expr $secs % 60`
  echo -e "${green}finished: $platforn build at: `date`, build time: $hours hours, $mins minutes, $secs seconds.${reset}"
done
