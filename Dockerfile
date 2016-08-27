FROM ubuntu:trusty
MAINTAINER Chris Kleeschulte <chrisk@bitpay.com>
ENV DEBIAN_FRONTEND noninteractive
WORKDIR /shared
RUN apt-get update && \
apt-get --no-install-recommends -yq install \
apt-cacher-ng \
locales \
git-core \
build-essential \
ca-certificates \
ruby \
rsync && \
apt-get -yq purge grub > /dev/null 2>&1 || true && \
apt-get -y dist-upgrade && \
locale-gen en_US.UTF-8 && \
update-locale LANG=en_US.UTF-8 && \
bash -c '[[ -d /shared/gitian-builder ]] || git clone -b alts_for_docker --depth 1 https://github.com/kleetus/gitian-builder /shared/gitian-builder' && \
useradd -d /home/ubuntu -m -s /bin/bash ubuntu && \
chown -R ubuntu.ubuntu /shared/ && \
chown root.root /shared/gitian-builder/target-bin/grab-packages.sh && \
chmod 755 /shared/gitian-builder/target-bin/grab-packages.sh && \
echo 'ubuntu ALL=(root) NOPASSWD:/usr/bin/apt-get,/shared/gitian-builder/target-bin/grab-packages.sh,/usr/sbin/apt-cacher-ng' > /etc/sudoers.d/ubuntu && \
chown root.root /etc/sudoers.d/ubuntu && \
chmod 0400 /etc/sudoers.d/ubuntu && \
chown -R ubuntu.ubuntu /home/ubuntu && \
echo 'Acquire::http::proxy "http://127.0.0.1:3142";' > /etc/apt/apt.conf.d/02proxy
USER ubuntu
RUN printf "\
mode='offlinemode=0' && \ 
[[ -z \"\$OFFLINE\" ]] || \
mode='offlinemode=1' && \
sudo /usr/sbin/apt-cacher-ng -c /etc/apt-cacher-ng pidfile=/var/run/apt-cacher-ng/pid SocketPath=/var/run/apt-cacher-ng/socket foreground=0 \$mode && \
[[ -d /shared/bitcoin ]] || \
git clone -b \$1 --depth 1 \$2 /shared/bitcoin && \
sudo apt-get --no-install-recommends -yq install \$( sed -ne '/^packages:/,/[^-] .*/ {/^- .*/{s/\"//g;s/- //;p}}' /shared/bitcoin/contrib/gitian-descriptors/*|sort|uniq )" > /home/ubuntu/cacheit.sh && \
printf "\
bash /home/ubuntu/cacheit.sh \$1 \$2 && \
cd /shared/gitian-builder; \
./bin/gbuild --commit bitcoin=\$1 --url bitcoin=\$2 \$3" > /home/ubuntu/runit.sh
CMD ["v0.12.1-bitcore-3","https://github.com/bitpay/bitcoin.git","../bitcoin/contrib/gitian-descriptors/gitian-linux.yml"]
ENTRYPOINT ["bash","/home/ubuntu/runit.sh"]
