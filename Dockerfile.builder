FROM ubuntu:trusty
MAINTAINER Chris Kleeschulte <chrisk@bitpay.com>
RUN useradd -d /home/ubuntu -m -s /bin/bash ubuntu && \
mkdir -p -m0755 /var/run/sshd && \
mkdir -p /home/ubuntu/.ssh && \
mkdir -p /root/.ssh && \
apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get --no-install-recommends -yq install \
locales \
git-core \
build-essential \
openssh-server \
openssh-client \
ca-certificates \
ruby \
rsync && \
locale-gen en_US.UTF-8 && \
update-locale LANG=en_US.UTF-8
RUN echo '#!/bin/bash' > /root/runit.sh && \
echo 'set -e' >> /root/runit.sh && \
echo '[[ -d /tmp/shared/gitian-builder ]] || git clone --depth 1 https://github.com/devrandom/gitian-builder /tmp/shared/gitian-builder' >> /root/runit.sh && \
echo "[[ -d /tmp/shared/bitcoin ]] || git clone -b v0.12.1-bitcore-2 --depth 1 https://github.com/bitpay/bitcoin.git /tmp/shared/bitcoin" >> /root/runit.sh && \
echo 'mkdir -p /tmp/shared/gitian-builder/var' >> /root/runit.sh && \
echo 'rm -fr /tmp/shared/gitian-builder/var/build.log' >> /root/runit.sh && \
echo "cd /tmp/shared/gitian-builder; cmd=\"./bin/gbuild --skip-image --allow-sudo --commit bitcoin=v0.12.1-bitcore-2  --url bitcoin=https://github.com/bitpay/bitcoin.git ../bitcoin/contrib/gitian-descriptors/gitian-win.yml\"; echo \$cmd; \${cmd}&" >> /root/runit.sh && \
echo 'while [ ! -e "var/build.log" ];' >> /root/runit.sh && \
echo 'do' >> /root/runit.sh && \
echo '  sleep 1' >> /root/runit.sh && \
echo 'done' >> /root/runit.sh && \
echo 'tail -f var/build.log' >> /root/runit.sh && \
chmod +x /root/runit.sh
CMD ["/root/runit.sh"]
