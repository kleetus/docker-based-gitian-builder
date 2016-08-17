FROM ubuntu:trusty
MAINTAINER Chris Kleeschulte <chrisk@bitpay.com>
ENV DEBIAN_FRONTEND noninteractive
WORKDIR /home/ubuntu
RUN useradd -d /home/ubuntu -m -s /bin/bash ubuntu && \
apt-get update && \
apt-get --no-install-recommends -yq install \
locales \
git-core \
build-essential \
openssh-server \
openssh-client \
ca-certificates \
ruby \
rsync && \
apt-get -yq purge grub > /dev/null 2>&1 || true && \
apt-get -y dist-upgrade && \
locale-gen en_US.UTF-8 && \
update-locale LANG=en_US.UTF-8
RUN echo 'ubuntu ALL=(root) NOPASSWD:/usr/bin/apt-get,/usr/bin/dpkg-query' > /etc/sudoers.d/apt && \
chown root.root /etc/sudoers.d/apt && \
chmod 0400 /etc/sudoers.d/apt && \
chown -R ubuntu.ubuntu /home/ubuntu
USER ubuntu
RUN echo '#!/bin/bash' > /home/ubuntu/runit.sh && \
echo 'set -e' >> /home/ubuntu/runit.sh && \
echo '[[ -d /home/ubuntu/shared/gitian-builder ]] || git clone -b alts_for_docker --depth 1 https://github.com/kleetus/gitian-builder /home/ubuntu/shared/gitian-builder' >> /home/ubuntu/runit.sh && \
echo '[[ -d /home/ubuntu/shared/bitcoin ]] || git clone -b $1 --depth 1 $2 /home/ubuntu/shared/bitcoin' >> /home/ubuntu/runit.sh && \
echo 'cd /home/ubuntu/shared/gitian-builder; ./bin/gbuild --skip-image --allow-sudo --commit bitcoin=$1 --url bitcoin=$2 $3' >> /home/ubuntu/runit.sh && \
chmod +x /home/ubuntu/runit.sh
CMD ["v0.12.1-bitcore-2", "https://github.com/bitpay/bitcoin.git", "../bitcoin/contrib/gitian-descriptors/gitian-linux.yml"]
ENTRYPOINT ["/home/ubuntu/runit.sh"]
