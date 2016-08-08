FROM debian:jessie
MAINTAINER Chris Kleeschulte <chrisk@bitpay>
RUN useradd -G sudo -d /home/debian -m debian 
RUN sudo apt-get update && \
sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq \
pciutils
git-core

