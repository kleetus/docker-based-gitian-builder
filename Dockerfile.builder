FROM ubuntu:trusty
MAINTAINER Chris Kleeschulte <chrisk@bitpay.com>
RUN useradd -d /home/ubuntu -m -s /bin/bash ubuntu && \
mkdir -p -m0755 /var/run/sshd && \
mkdir -p /home/ubuntu/.ssh && \
mkdir -p /root/.ssh && \
chown -R ubuntu.ubuntu /home/ubuntu/.ssh && \
apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get --no-install-recommends -yq install \
locales \
build-essential \
openssh-server \
rsync && \
sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
locale-gen en_US.UTF-8 && \
update-locale LANG=en_US.UTF-8
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
