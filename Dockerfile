FROM ubuntu:trusty
MAINTAINER Chris Kleeschulte <chrisk@bitpay.com>
ENV DEBIAN_FRONTEND noninteractive
WORKDIR /shared
RUN apt-get update && \
apt-get --no-install-recommends -yq install \
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
bash -c '[[ -d /shared/gitian-builder ]] || git clone -b more-power https://github.com/kleetus/gitian-builder /shared/gitian-builder' && \
useradd -d /home/ubuntu -m -s /bin/bash ubuntu && \
chown -R ubuntu.ubuntu /shared/ && \
chown root.root /shared/gitian-builder/target-bin/grab-packages.sh && \
chmod 755 /shared/gitian-builder/target-bin/grab-packages.sh && \
echo 'ubuntu ALL=(root) NOPASSWD:/usr/bin/apt-get,/shared/gitian-builder/target-bin/grab-packages.sh' > /etc/sudoers.d/ubuntu && \
chown root.root /etc/sudoers.d/ubuntu && \
chmod 0400 /etc/sudoers.d/ubuntu && \
chown -R ubuntu.ubuntu /home/ubuntu
USER ubuntu
RUN printf "if [ -z \"\${COMMIT}\" ]; then COMMIT=master; fi \n\
if [ -z \"\${URL}\" ]; then URL=https://github.com/bitpay/bitcoin; fi \n\
if [ -z \"\${CONFIG}\" ]; then CONFIG=../bitcoin/contrib/gitian-descriptors/gitian-linux.yml; fi \n\
[[ -d /shared/bitcoin ]] || \
git clone -b \$COMMIT --depth 1 \$URL /shared/bitcoin && \
cd /shared/gitian-builder; \
./bin/gbuild --skip-image --commit bitcoin=\$COMMIT --url bitcoin=\$URL \$CONFIG" > /home/ubuntu/runit.sh
ENTRYPOINT ["bash", "/home/ubuntu/runit.sh"]
